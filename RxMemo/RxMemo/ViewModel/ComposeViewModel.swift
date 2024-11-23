//
//  ComposeViewModel.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import Action
import Foundation
import RxCocoa
import RxSwift

class ComposeViewModel: CommonViewModel {
    
    // MARK: - Properties
    
    private let content: String?
    
    var initialText: Driver<String?> {
        return Observable.just(content).asDriver(onErrorJustReturn: nil)
    }
    
    let saveAction: Action<String, Void>
    let cancelAction: CocoaAction
    
    // MARK: - Lifecycle
    
    init(
        title: String,
        content: String? = nil,
        sceneCoordinator: SceneCoordinatorType,
        storage: MemoStorageType,
        saveAction: Action<String, Void>? = nil,
        cancelAction: CocoaAction? = nil
    ) {
        self.content = content
        
        self.saveAction = Action<String, Void> { input in
            if let action = saveAction {
                action.execute(input)
            }
            
            return sceneCoordinator.close(animated: true).asObservable().map { _ in }
        }
        
        self.cancelAction = CocoaAction {
            if let action = cancelAction {
                action.execute(())
            }
            
            return sceneCoordinator.close(animated: true).asObservable().map { _ in }
        }
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
}
