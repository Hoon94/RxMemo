//
//  ComposeViewController.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import UIKit

class ComposeViewController: UIViewController, ViewModelBindableType {
    
    // MARK: - Properties
    
    var viewModel: ComposeViewModel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "새 메모"
    }
    
    // MARK: - Helpers
    
    func bindViewModel() {
        
    }
}

// MARK: - Preview

#Preview {
    UINavigationController(rootViewController: ComposeViewController())
}
