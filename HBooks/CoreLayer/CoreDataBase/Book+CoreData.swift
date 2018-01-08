//
//  Book+CoreData.swift
//  HBooks
//
//  Created by Denis Karpenko on 04.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation
import CoreData
extension Book {
    static func insertBook(with element: BooksApiModel, popularity: Int, in context: NSManagedObjectContext) -> Book? {
        if let book = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context) as? Book {
            book.id = element.id
            book.title = element.title
            book.annotation = element.annotation
            book.authors = element.authors
            book.coverURL = element.coverURL
            book.coverPlaceholder = element.placeholder
            book.popularity = Int32(popularity)
            return book
        }
        return nil
    }
    static func findOrInsertBook(with element: BooksApiModel, popularity: Int, in context: NSManagedObjectContext) -> Book? {
        if let book = findBook(with: element.id, in: context) {
            return book
        }
        else{
            return insertBook(with: element, popularity: popularity, in: context)
        }
    }
    static func insertOrUpdate(with element: BooksApiModel, popularity: Int, in context: NSManagedObjectContext){
         if let book = findBook(with: element.id, in: context) {
            book.title = element.title
            book.authors = element.authors
            book.coverPlaceholder = element.placeholder
            book.annotation = element.annotation
            book.popularity = Int32(popularity)
            book.coverURL = element.coverURL
        }
        else{
            _ = insertBook(with: element, popularity: popularity, in: context)
        }
    }
    
    static func findBook(with id: String, in context: NSManagedObjectContext) -> Book? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print ("Model is not available in context")
            assert(false)
            return nil
        }
        var book : Book?
        guard let fetchRequest = Book.fetchRequestBooks(with: id,model: model) else {
            return nil
        }
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple books with same id found!")
            if let foundBooks = results.first {
                book = foundBooks
            }
        } catch {
            print ("Failed to fetch book: \(error)")
        }
        return book
    }
    
    static func fetchRequestBooks(with id: String, model: NSManagedObjectModel) -> NSFetchRequest<Book>? {
        let templateName = "BookId"
        
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["id": id]) as? NSFetchRequest<Book> else{
            assert(false,"No template with name \(templateName)")
            return nil
        }
        return fetchRequest
    }
    
}
