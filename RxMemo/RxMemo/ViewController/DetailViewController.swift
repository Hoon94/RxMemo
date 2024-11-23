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
    
    private let contentCell = UITableViewCell(style: .default, reuseIdentifier: "contentCell").then {
        var content = $0.defaultContentConfiguration()
        content.textProperties.numberOfLines = 0
        content.textProperties.lineBreakMode = .byWordWrapping
        $0.contentConfiguration = content
    }
    
    private let dateCell = UITableViewCell(style: .default, reuseIdentifier: "dateCell").then {
        var content = $0.defaultContentConfiguration()
        content.textProperties.color = .secondaryLabel
        content.textProperties.alignment = .center
        $0.contentConfiguration = content
    }
    
    private let deleteButton = UIBarButtonItem(systemItem: .trash).then {
        $0.tintColor = .red
    }
    
    private let editButton = UIBarButtonItem(systemItem: .compose)
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
                    cell.contentConfiguration = content
                    
                    return cell
                case 1:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") else { return UITableViewCell() }
                    
                    var content = cell.defaultContentConfiguration()
                    content.text = value
                    cell.contentConfiguration = content
                    
                    return cell
                default:
                    fatalError()
                }
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func configureLayout() {
        addNavigationBar()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.directionalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        addToolBar()
    }
    
    private func addNavigationBar() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return }
        
        let statusBarHeight = window.safeAreaInsets.top
        
        let navigationBar = UINavigationBar(frame: .init(x: 0, y: statusBarHeight, width: view.frame.width, height: statusBarHeight))
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        
        let navigationItem = UINavigationItem(title: "메모 보기")
        navigationBar.items = [navigationItem]
        
        view.addSubview(navigationBar)
    }
    
    private func addToolBar() {
        navigationController?.isToolbarHidden = false
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [deleteButton, flexibleSpace, editButton, flexibleSpace, shareButton]
    }
}

// MARK: - Preview

#Preview {
    UINavigationController(rootViewController: DetailViewController())
}
