//
//  ListViewController.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/19/24.
//

import Action
import NSObject_Rx
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import Then
import UIKit

class ListViewController: UIViewController, ViewModelBindableType {
    
    // MARK: - Properties
    
    var viewModel: ListViewModel!
    
    private var addButton = UIBarButtonItem(systemItem: .add)
    
    private let tableView = UITableView().then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
    
    private let dataSource = RxTableViewSectionedAnimatedDataSource<MemoSectionModel>(configureCell: { dataSource, tableView, indexPath, memo -> UITableViewCell in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = memo.content
        content.textProperties.numberOfLines = 1
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }).then {
        $0.canEditRowAtIndexPath = { dataSource, index in
            return true
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "메모 목록"
        configureLayout()
    }
    
    // MARK: - Helpers
    
    func bindViewModel() {
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.memoList
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        addButton.rx.action = viewModel.makeCreateAction()
        
        Observable.zip(tableView.rx.modelSelected(Memo.self), tableView.rx.itemSelected)
            .withUnretained(self)
            .do(onNext: { viewController, data in
                viewController.tableView.deselectRow(at: data.1, animated: true)
            })
            .map { $1.0 }
            .bind(to: viewModel.detailAction.inputs)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelDeleted(Memo.self)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.deleteAction.inputs)
            .disposed(by: rx.disposeBag)
    }
    
    private func configureLayout() {
        navigationItem.rightBarButtonItem = addButton
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.directionalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Preview

#Preview {
    let navigation = UINavigationController(rootViewController: ListViewController())
    navigation.navigationBar.prefersLargeTitles = true
    
    return navigation
}
