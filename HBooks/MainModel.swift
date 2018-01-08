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

// IMainModel = Facade + DownloaderManager

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

class MainModel {
    private var curPage: Int = 1
    internal var noMoreBooks: Bool = false
    internal weak var delegate: IMainModelDelegate?
    private let listService: ListDownloaderService
    private let coreDataStack = CoreDataStack()
    private let storageManager: IStorageManager
    private let imageDownloader: IImageDownloaderService = ImageDownloaderService()
    private var isDonwloading = false
    private let dataSource: IDataSource
    init(tableView: UITableView) {
        let requestSender = RequestSender()
        listService = ListDownloaderService(requestSender: requestSender)
        storageManager = StorageManager(with: coreDataStack)
        self.dataSource = BooksDataSource(tableView: tableView, mainContext: coreDataStack.mainContext)
        self.refresh()
    }
}

// MARK: - IMainModel

extension MainModel : IMainModel {
    var numberOfElements: Int {
        return dataSource.numberOfElements
    }
    
    func object(at index: IndexPath) -> Book {
        return dataSource.object(at: index)
    }
    
    
    func refresh(){
        if isDonwloading == false {
            //imageDownloader.terminateAllDownloads() almost everytime it is not required
            downloadMore(page: 1, start: 0)
        }
    }
    
    func loadMore(){
        if isDonwloading == false && noMoreBooks == false {
            downloadMore(page: curPage, start: numberOfElements)
        }
    }
    
    
    func downloadMore(page: Int, start: Int){
        isDonwloading = true
        listService.downloadList(page: page) {[weak self] (booksList, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.isDonwloading = false
                strongSelf.delegate?.show(error: error)
                return
            }
            if let booksList = booksList {
                if booksList.isEmpty {
                    strongSelf.noMoreBooks = true
                    strongSelf.isDonwloading = false
                    strongSelf.delegate?.noMoreBooks()
                }
                else {
                    strongSelf.storageManager.save(elements: booksList, start: start) {[weak self] (error) in
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
    
    func downloadImage(with book: Book) {
        imageDownloader.downloadImage(with: book) {[weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .Success(let image):
                strongSelf.storageManager.updateBook(with: image, id: book.id!, completionHandler: {[weak self] (error) in
                    guard let strongSelf = self else { return }
                    if let error = error {
                        strongSelf.delegate?.show(error: error)
                    }
                })
            case .Fail(let error):
                    //self.delegate?.show(error: error) When The Internet goes offline this alert will spam too much
                    print(error)
            }
        }
    }
}
