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
    static func insertBook(with id: String,title: String, annotation: String, authors: String, coverURL: String, placeholder: Data?, popularity: Int, in context: NSManagedObjectContext) -> Book? {
        if let book = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context) as? Book {
            book.id = id
            book.title = title
            book.annotation = annotation
            book.authors = authors
            book.coverURL = coverURL
            book.coverPlaceholder = placeholder
            book.popularity = Int32(popularity)
            return book
        }
        return nil
    }
    static func findOrInsertBook(with id: String, title: String, annotation: String, authors: String, coverURL: String, placeholder: Data?, popularity: Int, in context: NSManagedObjectContext) -> Book? {
        if let book = findBook(with: id, in: context) {
            return book
        }
        else{
            return insertBook(with: id, title: title, annotation: annotation, authors: authors, coverURL: coverURL, placeholder: placeholder,popularity: popularity, in: context)
        }
    }
    static func insertOrUpdate(with id: String, title: String, annotation: String, authors: String, coverURL: String, placeholder: Data?, popularity: Int, in context: NSManagedObjectContext){
         if let book = findBook(with: id, in: context) {
            book.title = title
            book.authors = authors
            book.coverPlaceholder = placeholder
            book.annotation = annotation
            book.popularity = Int32(popularity)
            book.coverURL = coverURL

        }
        else{
            _ = insertBook(with: id, title: title, annotation: annotation, authors: authors, coverURL: coverURL, placeholder: placeholder,popularity: popularity, in: context)
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
