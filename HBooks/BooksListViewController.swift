//
//  BooksListViewController.swift
//  HBooks
//
//  Created by Denis Karpenko on 03.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import UIKit
import SafariServices

class BooksListViewController: UIViewController {
    @IBOutlet weak var booksTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private let bottomActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    @IBOutlet weak var centerActivityIndicator: UIActivityIndicatorView!
    
    private var mainModel: IMainModel!
    private let downloadOffset = 0 // set position before the end when we start to download a new batch of news
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
    }
    
    func configureController() {
        mainModel = MainModel(tableView: booksTableView)
        mainModel.delegate = self
        booksTableView.delegate = self
        booksTableView.dataSource = self
        booksTableView.backgroundView = refreshControl
        booksTableView.tableFooterView = bottomActivityIndicator
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "обновление", attributes: nil)
    }
    
    @objc private func refreshData(){
        mainModel.refresh()
    }
}

// MARK: - IMainModelDelegate

extension BooksListViewController: IMainModelDelegate {
    func show(error message: String) {
        let alert = UIAlertController(title: "Упс, проблема", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default) { action in
            self.stopRefresh() //small fix because of alert and pull refresh at the same time
            self.centerActivityIndicator.stopAnimating()
            self.booksTableView.tableFooterView?.isHidden = true
        })
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func stopRefresh(){
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    func noMoreBooks(){
        // show about the ending of list?
//        let alert = UIAlertController(title: "Упс, проблема", message: "Список популярных книг закончился", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ок", style: .default) { action in
//            //self.myActivityIndicator.isDownloading = false
//        })
        DispatchQueue.main.async {
            self.booksTableView.tableFooterView?.isHidden = true
            self.booksTableView.tableFooterView = nil
            //self.present(alert, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension BooksListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = mainModel.numberOfElements
        if num > 0 {
            centerActivityIndicator.stopAnimating()
        }
        return num
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookTableViewCell
        
        configureCell(cell: cell, with: mainModel.object(at: indexPath))
        return cell
    }
    
    func configureCell(cell: BookTableViewCell, with data: Book) {
        cell.titleLabel.text = data.title
        cell.annotationLabel.text = data.annotation
        cell.authorsLabel.text = data.authors
        if data.coverImage == nil {
            mainModel.downloadImage(with: data)
            cell.coverImage.image = UIImage(data: data.coverPlaceholder!)
        }
        else{
            cell.coverImage.image = UIImage(data: data.coverImage!)
        }
    }
}


// MARK: - UITableViewDelegate
extension BooksListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if mainModel.numberOfElements == indexPath.row + 1 + downloadOffset {
            if mainModel.noMoreBooks == false {
                booksTableView.tableFooterView?.isHidden = false
                bottomActivityIndicator.startAnimating()
                mainModel.loadMore()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        booksTableView.deselectRow(at: indexPath, animated: true)
        let bookID = mainModel.object(at: indexPath).id
        let svc = SFSafariViewController(url: URL(string: "https://bookmate.com/books/\(bookID!)")!)
        self.present(svc, animated: true, completion: nil)
    }
}


