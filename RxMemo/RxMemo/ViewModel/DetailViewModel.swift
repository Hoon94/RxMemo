//
//  DetailViewModel.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import Action
import Foundation
import RxCocoa
import RxSwift
import Then

class DetailViewModel: CommonViewModel {
    
    // MARK: - Properties
    
    let memo: Memo
    
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
}
