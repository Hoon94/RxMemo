//
//  ListViewController.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/19/24.
//

import UIKit

class ListViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "메모 목록"
    }
}

// MARK: - Preview

#Preview {
    let navigation = UINavigationController(rootViewController: ListViewController())
    navigation.navigationBar.prefersLargeTitles = true
    
    return navigation
}
