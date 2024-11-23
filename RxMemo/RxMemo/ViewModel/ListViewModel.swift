//
//  ListViewModel.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import Action
import Foundation
import RxCocoa
import RxSwift

class ListViewModel: CommonViewModel {
    
    // MARK: - Properties
    
    var memoList: Observable<[Memo]> {
        return storage.memoList()
    }
    
    // MARK: - Helpers
    
    func makeCreateAction() -> CocoaAction {
        return CocoaAction { _ in
            return self.storage.createMemo(content: "")
                .flatMap { [unowned self] memo -> Observable<Void> in
                    let composeViewModel = ComposeViewModel(title: "새 메모", sceneCoordinator: self.sceneCoordinator, storage: self.storage, saveAction: self.performUpdate(memo: memo), cancelAction: self.performCancel(memo: memo))
                    let composeScene = Scene.compose(composeViewModel)
                    
                    return self.sceneCoordinator.transition(to: composeScene, using: .modal, animated: true)
                        .asObservable()
                        .map { _ in }
                }
        }
    }
    
    private func performUpdate(memo: Memo) -> Action<String, Void> {
        return Action { [unowned self] input in
            return self.storage.update(memo: memo, content: input).map { _ in }
        }
    }
    
    private func performCancel(memo: Memo) -> CocoaAction {
        return Action { [unowned self] in
            return self.storage.delete(memo: memo).map { _ in }
        }
    }
}
