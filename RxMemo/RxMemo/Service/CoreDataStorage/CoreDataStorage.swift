//
//  CoreDataStorage.swift
//  RxMemo
//
//  Created by Daehoon Lee on 11/28/24.
//

import CoreData
import Foundation

import RxSwift

class CoreDataStorage: MemoStorageType {
    
    // MARK: - Properties
    
    let modelName: String
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    private var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Lifecycle
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: - Helpers
    
    @discardableResult
    func createMemo(content: String) -> RxSwift.Observable<Memo> {
        let memo = Memo(content: content)
        
        do {
            _ = try mainContext.rx.update(memo)
            
            return Observable.just(memo)
        } catch {
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func memoList() -> RxSwift.Observable<[MemoSectionModel]> {
        return mainContext.rx.entities(Memo.self, sortDescriptors: [NSSortDescriptor(key: "insertDate", ascending: false)])
            .map { results in [MemoSectionModel(model: 0, items: results)] }
    }
    
    @discardableResult
    func update(memo: Memo, content: String) -> RxSwift.Observable<Memo> {
        let updated = Memo(original: memo, updatedContent: content)
        
        do {
            _ = try mainContext.rx.update(updated)
            
            return Observable.just(updated)
        } catch {
            return Observable.error(error)
        }
    }
    
    @discardableResult
    func delete(memo: Memo) -> RxSwift.Observable<Memo> {
        do {
            try mainContext.rx.delete(memo)
            
            return Observable.just(memo)
        } catch {
            return Observable.error(error)
        }
    }
}
