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
    let entityName: String
    
    private var list: [Memo] {
        return fetchMemo().map { Memo(entity: $0) }
    }
    
    private lazy var sectionModel = MemoSectionModel(model: 0, items: list)
    
    private lazy var store = BehaviorSubject<[MemoSectionModel]>(value: [sectionModel])
    
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
    
    private var memoEntity: NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: mainContext)
    }
    
    // MARK: - Lifecycle
    
    init(modelName: String, entityName: String) {
        self.modelName = modelName
        self.entityName = entityName
    }
    
    // MARK: - Helpers
    
    @discardableResult
    func createMemo(content: String) -> RxSwift.Observable<Memo> {
        let memo = Memo(content: content)
        
        if let entity = memoEntity {
            let managedObject = NSManagedObject(entity: entity, insertInto: mainContext)
            managedObject.setValue(memo.content, forKey: "content")
            managedObject.setValue(memo.insertDate, forKey: "insertDate")
            managedObject.setValue(memo.identity, forKey: "identity")
            saveContext()
            
            sectionModel.items.insert(memo, at: 0)
            store.onNext([sectionModel])
        }
        
        return Observable.just(memo)
    }
    
    @discardableResult
    func memoList() -> RxSwift.Observable<[MemoSectionModel]> {
        return store
    }
    
    @discardableResult
    func update(memo: Memo, content: String) -> RxSwift.Observable<Memo> {
        let updated = Memo(original: memo, updatedContent: content)
        let results = fetchMemo()
        
        for result in results {
            if result.identity == updated.identity {
                updated.update(result)
            }
        }
        
        if let index = sectionModel.items.firstIndex(where: { $0 == memo }) {
            sectionModel.items.remove(at: index)
            sectionModel.items.insert(updated, at: index)
        }
        
        store.onNext([sectionModel])
        
        return Observable.just(updated)
    }
    
    @discardableResult
    func delete(memo: Memo) -> RxSwift.Observable<Memo> {
        let results = fetchMemo()
        let deleted = results.filter { $0.identity == memo.identity }[0]
        
        mainContext.delete(deleted)
        saveContext()
        
        if let index = sectionModel.items.firstIndex(where: { $0 == memo }) {
            sectionModel.items.remove(at: index)
        }
        
        store.onNext([sectionModel])
        
        return Observable.just(memo)
    }
    
    private func saveContext() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func fetchMemo() -> [MemoEntity] {
        do {
            let request = MemoEntity.fetchRequest()
            let sortByDate = NSSortDescriptor(key: "insertDate", ascending: false)
            request.sortDescriptors = [sortByDate]
            let results = try mainContext.fetch(request)
            
            return results
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
}
