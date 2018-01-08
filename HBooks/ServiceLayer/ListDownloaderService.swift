//
//  ListDownloaderService.swift
//  HBooks
//
//  Created by Denis Karpenko on 03.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit

protocol IListDownloaderService {
    func downloadList(page: Int,completionHandler: @escaping ([BooksApiModel]?, String?) -> Void)
}

class ListDownloaderService: IListDownloaderService {
    
    private let requestSender: IRequestSender
    
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    
    func downloadList(page: Int, completionHandler: @escaping ([BooksApiModel]?, String?) -> Void) {
        let requestConfig: RequestConfig<[BooksApiModel]> = RequestsConfigFactory.listConfig(page: page)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestSender.send(config: requestConfig) { (result: Result<[BooksApiModel]>) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            switch result {
            case .Success(let books):
                completionHandler(books, nil)
            case .Fail(let error):
                completionHandler(nil, error)
            }
        }
        
    }
}



