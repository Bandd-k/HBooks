//
//  DataSource.swift
//  HBooks
//
//  Created by Denis Karpenko on 09.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol IDataSource {
    var numberOfElements: Int { get }
    func object(at index: IndexPath) -> Book
}

class BooksDataSource: NSObject, IDataSource {
    
    private let fetchedResultsController: NSFetchedResultsController<Book>
    private unowned let tableView: UITableView
    
    var numberOfElements: Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections[0].numberOfObjects// only one section
    }
    
    func object(at index: IndexPath) -> Book {
        return  fetchedResultsController.object(at: index)
    }
    
    init(tableView: UITableView, mainContext: NSManagedObjectContext?) {
        self.tableView = tableView
        let context = mainContext
        let fetchRequest = NSFetchRequest<Book>(entityName: "Book")
        let sortByPopularity = NSSortDescriptor(key: "popularity",ascending: true)
        fetchRequest.sortDescriptors = [sortByPopularity]
        fetchedResultsController = NSFetchedResultsController<Book>(fetchRequest:
            fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil,
                          cacheName: nil)
        super.init()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print ("Error fetching: \(error)")
        }
        
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension BooksDataSource: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange  anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

