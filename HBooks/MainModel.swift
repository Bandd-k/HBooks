//
//  MainModel.swift
//  HBooks
//
//  Created by Denis Karpenko on 04.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol IMainModel {
    weak var delegate: IMainModelDelegate? { get set }
    var numberOfElements: Int { get }
    var noMoreBooks: Bool { get }
    func object(at index: IndexPath) -> Book
    func loadMore()
    func refresh()
    func downloadImage(with book: Book)
}

protocol IMainModelDelegate: class {
    func show(error message: String)
    func stopRefresh()
    func noMoreBooks()
    
}
class MainModel: NSObject {
    private var curPage: Int = 1
    internal var noMoreBooks: Bool = false
    internal weak var delegate: IMainModelDelegate?
    private unowned let tableView: UITableView
    private let fetchedResultsController: NSFetchedResultsController<Book>
    private let listService: ListDownloaderService
    private let coreDataStack = CoreDataStack()
    private let storageManager: IStorageManager
    private let imageDownloader: IImageDownloaderService = ImageDownloaderService()
    private var isDonwloading = false
    private let dataSource: IDataSource
    init(tableView: UITableView) {
        let requestSender = RequestSender()
        listService = ListDownloaderService(requestSender: requestSender)
        //contentService = ContentDownloaderService(requestSender: requestSender)
        storageManager = StorageManager(with: coreDataStack)
        
        // NSFetchedResultsController
        self.dataSource = BooksDataSource(tableView: tableView, mainContext: coreDataStack.mainContext)
        self.tableView = tableView
        let context = coreDataStack.mainContext
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
            self.delegate?.show(error: "Error fetching: \(error)")
        }
        refresh()
    }

}


// MARK: - IMainModel

extension MainModel : IMainModel {
    var numberOfElements: Int {
        return dataSource.numberOfElements
//        guard let sections = fetchedResultsController.sections else {
//            return 0
//        }
//        return sections[0].numberOfObjects// only one section
    }
    
    func object(at index: IndexPath) -> Book {
        return dataSource.object(at: index)
    }
    
    func downloadMore(page: Int, start: Int){
        isDonwloading = true
        listService.downloadList(page: page) {[weak self] (newsList, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.isDonwloading = false
                strongSelf.delegate?.show(error: error)
                return
            }
            if let newsList = newsList {
                if newsList.isEmpty {
                    strongSelf.noMoreBooks = true
                    strongSelf.isDonwloading = false
                    strongSelf.delegate?.noMoreBooks()
                }
                else {
                    strongSelf.storageManager.save(elements: newsList, start: start) {[weak self] (error) in
                        guard let strongSelf = self else { return }
                        strongSelf.isDonwloading = false
                        if let error = error {
                            strongSelf.delegate?.show(error: error)
                            return
                        }
                        strongSelf.noMoreBooks = false
                        strongSelf.curPage = page + 1
                        strongSelf.delegate?.stopRefresh()
                    }
                }
            }
        }
        
    }
    
    func refresh(){
        if isDonwloading == false {
            downloadMore(page: 1, start: 0)
        }
    }
    
    func loadMore(){
        if isDonwloading == false && noMoreBooks == false {
            downloadMore(page: curPage, start: numberOfElements)
        }
        
    }
    
    
    func downloadImage(with book: Book) {
         // SELF CAPTURING
        imageDownloader.downloadImage(with: book) { (result) in
            switch result {
            case .Success(let image):
                self.storageManager.updateBook(with: image, id: book.id!, completionHandler: { (error) in
                    if let error = error {
                        self.delegate?.show(error: error)
                    }
                })
            case .Fail(let error):
                    //self.delegate?.show(error: error) When The Internet goes offline this alert will spam too much
                    print(error)
            }
        }
        
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension MainModel: NSFetchedResultsControllerDelegate {
    
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
