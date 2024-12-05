//
//  ComposeViewController.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import Action
import NSObject_Rx
import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ComposeViewController: UIViewController, ViewModelBindableType {
    
    // MARK: - Properties
    
    var viewModel: ComposeViewModel!
    
    private var cancelButton = UIBarButtonItem(systemItem: .cancel)
    private let saveButton = UIBarButtonItem(systemItem: .save)
    private let contentTextView = UITextView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "새 메모"
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        }
    }
    
    // MARK: - Helpers
    
    func bindViewModel() {
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.initialText
            .drive(contentTextView.rx.text)
            .disposed(by: rx.disposeBag)
        
        cancelButton.rx.action = viewModel.cancelAction
        
        saveButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .withLatestFrom(contentTextView.rx.text.orEmpty)
            .bind(to: viewModel.saveAction.inputs)
            .disposed(by: rx.disposeBag)
        
        let willShowObservable = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
            .map { $0.cgRectValue.height }
        
        let willHideObservable = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { notification -> CGFloat in 0 }
        
        let keyboardObservable = Observable.merge(willShowObservable, willHideObservable)
            .share()
        
        keyboardObservable
            .toContentInset(of: contentTextView)
            .bind(to: contentTextView.rx.contentInset)
            .disposed(by: rx.disposeBag)
        
        keyboardObservable
            .toVerticalScrollIndicatorInsets(of: contentTextView)
            .bind(to: contentTextView.rx.verticalScrollIndicatorInsets)
            .disposed(by: rx.disposeBag)
    }
    
    private func configureLayout() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.directionalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - ObservableType

extension ObservableType where Element == CGFloat {
    func toContentInset(of textView: UITextView) -> Observable<UIEdgeInsets> {
        return map { height in
            var inset = textView.contentInset
            inset.bottom = height
            return inset
        }
    }
    
    func toVerticalScrollIndicatorInsets(of textView: UITextView) -> Observable<UIEdgeInsets> {
        return map { height in
            var scrollInset = textView.verticalScrollIndicatorInsets
            scrollInset.bottom = height
            return scrollInset
        }
    }
}

// MARK: - Preview

#Preview {
    UINavigationController(rootViewController: ComposeViewController())
}
