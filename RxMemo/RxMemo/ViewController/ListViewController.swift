//
//  ListViewController.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/19/24.
//

import NSObject_Rx
import RxCocoa
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
    
    private let cell = UITableViewCell(style: .default, reuseIdentifier: "cell").then {
        $0.accessoryType = .disclosureIndicator
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
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { row, memo, cell in
                var content = cell.defaultContentConfiguration()
                content.text = memo.content
                cell.contentConfiguration = content
            }
            .disposed(by: rx.disposeBag)
        
        addButton.rx.action = viewModel.makeCreateAction()
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
