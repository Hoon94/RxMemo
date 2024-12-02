//
//  DetailViewModel.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import Action
import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import Then

class DetailViewModel: CommonViewModel {
    
    // MARK: - Properties
    
    var memo: Memo
    
    private var formatter = DateFormatter().then {
        $0.locale = Locale(identifier: Locale.current.language.languageCode?.identifier ?? "en_US")
        $0.dateStyle = .medium
        $0.timeStyle = .medium
    }
    
    var contents: BehaviorSubject<[String]>
    
    // MARK: - Lifecycle
    
    init(memo: Memo, title: String, sceneCoordinator: SceneCoordinatorType, storage: MemoStorageType) {
        self.memo = memo
        
        contents = BehaviorSubject(value: [
            memo.content,
            formatter.string(from: memo.insertDate)
        ])
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
    
    // MARK: - Helpers
    
    func makeDeleteAction() -> CocoaAction {
        return Action { input in
            self.storage.delete(memo: self.memo)
            
            return self.sceneCoordinator.close(animated: true)
                .asObservable()
                .map { _ in }
        }
    }
    
    func makeEditAction() -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let composeViewModel = ComposeViewModel(title: "메모 편집", content: self.memo.content, sceneCoordinator: self.sceneCoordinator, storage: self.storage, saveAction: self.performUpdate(memo: self.memo))
            let composeScene = Scene.compose(composeViewModel)
            
            return self.sceneCoordinator.transition(to: composeScene, using: .modal, animated: true)
                .asObservable()
                .map { _ in }
        }
    }
    
    private func performUpdate(memo: Memo) -> Action<String, Void> {
        return Action { [unowned self] input in
            self.storage.update(memo: memo, content: input)
                .do(onNext: { self.memo = $0 })
                .map { [$0.content, self.formatter.string(from: $0.insertDate)] }
                .bind(onNext: { self.contents.onNext($0) })
                .disposed(by: self.rx.disposeBag)
            
            return Observable.empty()
        }
    }
}
