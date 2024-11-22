//
//  ListViewModel.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/21/24.
//

import Foundation
import RxCocoa
import RxSwift

class ListViewModel: CommonViewModel {
    
    // MARK: - Properties
    
    var memoList: Observable<[Memo]> {
        return storage.memoList()
    }
}
