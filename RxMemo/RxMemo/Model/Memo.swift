//
//  Memo.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/20/24.
//

import Foundation
import RxDataSources

struct Memo: Equatable, IdentifiableType {
    
    // MARK: - Properties
    
    var content: String
    var insertDate: Date
    var identity: String
    
    // MARK: - Lifecycle
    
    init(content: String, insertDate: Date = Date()) {
        self.content = content
        self.insertDate = insertDate
        self.identity = "\(insertDate.timeIntervalSinceReferenceDate)"
    }
    
    init(original: Memo, updatedContent: String) {
        self = original
        self.content = updatedContent
    }
}
