//
//  DetailViewController.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import NSObject_Rx
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
    
    private let deleteButton = UIBarButtonItem(systemItem: .trash).then {
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
        
        editButton.rx.action = viewModel.makeEditAction()
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
