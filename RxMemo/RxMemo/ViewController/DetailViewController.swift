//
//  DetailViewController.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import UIKit

class DetailViewController: UIViewController {
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addNavigationBar()
    }
    
    // MARK: - Helpers
    
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
}

// MARK: - Preview

#Preview {
    DetailViewController()
}
