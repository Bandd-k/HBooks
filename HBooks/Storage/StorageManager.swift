//
//  StorageManager.swift
//  HBooks
//
//  Created by Denis Karpenko on 04.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol IStorageManager {
    func save(elements: [BooksApiModel], start: Int, completionHandler: @escaping (String?) -> Void)
    func updateBook(with image: UIImage, id: String, completionHandler: @escaping (String?) -> Void)
}

class StorageManager: IStorageManager {
    private let coreDataStack:CoreDataStack
    init(with coreStack:CoreDataStack){
        coreDataStack = coreStack
    }
    func save(elements:[BooksApiModel], start: Int, completionHandler: @escaping (String?) -> Void){
        guard let context = coreDataStack.saveContext else {
            completionHandler("no saveContext")
            return
        }
        for (index,element) in elements.enumerated() {
            _ = Book.insertOrUpdate(with: element, popularity: index + start, in: context)
        }
        if (start == 0) {
            let fetchRequest = NSFetchRequest<Book>(entityName: "Book")
            let sortByPopularity = NSSortDescriptor(key: "popularity",ascending: true)
            fetchRequest.sortDescriptors = [sortByPopularity]
            do {
                let result = try context.fetch(fetchRequest)  //delete everything  except just downloaded entites
                let batch = elements.count
                for object in result[batch...] {
                    context.delete(object)
                }
            } catch {
                completionHandler("Error fetching: \(error)")
            }
        }
        coreDataStack.performSave(context: context, completionHandler: completionHandler)
    }
    
    func updateBook(with image: UIImage, id: String, completionHandler: @escaping (String?) -> Void) {
        guard let context = coreDataStack.mainContext else {
            completionHandler("no saveContext")
            return
        }
        let book = Book.findBook(with: id, in: context)
        book?.coverImage = UIImagePNGRepresentation(image)
        coreDataStack.performSave(context: context, completionHandler: completionHandler)
    }
}

