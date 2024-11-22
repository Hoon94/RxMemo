//
//  SceneCoordinatorType.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/22/24.
//

import Foundation
import RxSwift

protocol SceneCoordinatorType {
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable
    
    @discardableResult
    func close(animated: Bool) -> Completable
}
