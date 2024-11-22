//
//  TransitionModel.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/22/24.
//

import Foundation

// MARK: - TransitionStyle

enum TransitionStyle {
    case root
    case push
    case modal
}

// MARK: - TransitionError

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}
