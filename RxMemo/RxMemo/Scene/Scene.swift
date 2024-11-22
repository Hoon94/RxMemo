//
//  Scene.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/22/24.
//

import UIKit

enum Scene {
    case list(ListViewModel)
    case detail(DetailViewModel)
    case compose(ComposeViewModel)
}

extension Scene {
    func instantiate() -> UIViewController {
        switch self {
        case .list(let listViewModel):
            var listViewController = ListViewController()
            listViewController.bind(viewModel: listViewModel)
            
            let listNavigationController = UINavigationController(rootViewController: listViewController)
            
            return listNavigationController
        case .detail(let detailViewModel):
            var detailViewController = DetailViewController()
            detailViewController.bind(viewModel: detailViewModel)
            
            return detailViewController
        case .compose(let composeViewModel):
            var composeViewController = ComposeViewController()
            composeViewController.bind(viewModel: composeViewModel)
            
            let composeNavigationController = UINavigationController(rootViewController: composeViewController)
            
            return composeNavigationController
        }
    }
}
