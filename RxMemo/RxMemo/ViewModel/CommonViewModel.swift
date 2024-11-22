//
//  CommonViewModel.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/22/24.
//

import Foundation
import RxCocoa
import RxSwift

class CommonViewModel: NSObject {
    
    // MARK: - Properties
    
    let title: Driver<String>
    
    let sceneCoordinator: SceneCoordinatorType
    let storage: MemoStorageType
    
    // MARK: - Lifecycle
    
    init(title: String, sceneCoordinator: SceneCoordinatorType, storage: MemoStorageType) {
        self.title = Observable.just(title).asDriver(onErrorJustReturn: "")
        self.sceneCoordinator = sceneCoordinator
        self.storage = storage
    }
}
