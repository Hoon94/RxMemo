//
//  DetailViewController.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import Action
import NSObject_Rx
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class DetailViewController: UIViewController, ViewModelBindableType {
    
    // MARK: - Properties
    
    var viewModel: DetailViewModel!
    
    private let tableView = UITableView().then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "contentCell")
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "dateCell")
        $0.allowsSelection = false
        $0.separatorStyle = .none
    }
    
    private let contentCell = UITableViewCell(style: .default, reuseIdentifier: "contentCell")
    private let dateCell = UITableViewCell(style: .default, reuseIdentifier: "dateCell")
    
    private var deleteButton = UIBarButtonItem(systemItem: .trash).then {
        $0.tintColor = .red
    }
    
    private var editButton = UIBarButtonItem(systemItem: .compose)
    private let shareButton = UIBarButtonItem(systemItem: .action)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
    }
    
    // MARK: - Helpers
    
    func bindViewModel() {
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.contents
            .bind(to: tableView.rx.items) { tableView, row, value in
                switch row {
                case 0:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell") else { return UITableViewCell() }
                    
                    var content = cell.defaultContentConfiguration()
                    content.text = value
                    content.textProperties.numberOfLines = 0
                    content.textProperties.lineBreakMode = .byWordWrapping
                    cell.contentConfiguration = content
                    
                    return cell
                case 1:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") else { return UITableViewCell() }
                    
                    var content = cell.defaultContentConfiguration()
                    content.text = value
                    content.textProperties.color = .secondaryLabel
                    content.textProperties.alignment = .center
                    cell.contentConfiguration = content
                    
                    return cell
                default:
                    fatalError()
                }
            }
            .disposed(by: rx.disposeBag)
        
        deleteButton.rx.action = viewModel.makeDeleteAction()
        
        editButton.rx.action = viewModel.makeEditAction()
        
        shareButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                let memo = viewController.viewModel.memo.content
                
                let activityViewController = UIActivityViewController(activityItems: [memo], applicationActivities: nil)
                viewController.present(activityViewController, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func configureLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.directionalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        addToolBar()
    }
    
    private func addToolBar() {
        navigationController?.isToolbarHidden = false
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [deleteButton, flexibleSpace, editButton, flexibleSpace, shareButton]
    }
}

// MARK: - Preview

#Preview {
    let navigationController = UINavigationController(rootViewController: DetailViewController())
    navigationController.isToolbarHidden = false
    
    return navigationController
}
