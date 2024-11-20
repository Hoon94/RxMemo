//
//  ComposeViewController.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import UIKit

class ComposeViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "새 메모"
    }
}

// MARK: - Preview

#Preview {
    UINavigationController(rootViewController: ComposeViewController())
}
