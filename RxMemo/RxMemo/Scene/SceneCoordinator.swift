//
//  SceneCoordinator.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/22/24.
//

import RxCocoa
import RxSwift
import UIKit

class SceneCoordinator: SceneCoordinatorType {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private var window: UIWindow
    private var currentViewController: UIViewController
    
    // MARK: - Lifecycle
    
    required init(window: UIWindow) {
        self.window = window
        currentViewController = window.rootViewController ?? UIViewController()
    }
    
    // MARK: - Helpers
    
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> RxSwift.Completable {
        let subject = PublishSubject<Never>()
        
        let target = scene.instantiate()
        
        switch style {
        case .root:
            currentViewController = target
            window.rootViewController = target
            
            subject.onCompleted()
        case .push:
            guard let navigationController = currentViewController.navigationController else {
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            
            navigationController.pushViewController(target, animated: animated)
            currentViewController = target
            
            subject.onCompleted()
        case .modal:
            currentViewController.present(target, animated: animated) {
                subject.onCompleted()
            }
            
            currentViewController = target
        }
        
        return subject.asCompletable()
    }
    
    @discardableResult
    func close(animated: Bool) -> RxSwift.Completable {
        return Completable.create { [unowned self] completable in
            if let presentingViewController = self.currentViewController.presentingViewController {
                self.currentViewController.dismiss(animated: animated) {
                    self.currentViewController = presentingViewController
                    completable(.completed)
                }
            } else if let navigationController = self.currentViewController.navigationController {
                guard navigationController.popViewController(animated: animated) != nil else {
                    completable(.error(TransitionError.cannotPop))
                    return Disposables.create()
                }
                
                self.currentViewController = navigationController.viewControllers.last ?? UIViewController()
                completable(.completed)
            } else {
                completable(.error(TransitionError.unknown))
            }
            
            return Disposables.create()
        }
    }
}
