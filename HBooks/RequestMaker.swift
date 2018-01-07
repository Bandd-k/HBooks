//
//  RequestMaker.swift
//  HBooks
//
//  Created by Denis Karpenko on 03.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//
import Foundation

protocol IRequestMaker {
    func contentRequest(id: String) -> URLRequest?
    func listRequest(page: Int) -> URLRequest?
}

class RequestMaker: IRequestMaker {
    // https://api.bookmate.com/api/v5/books/popular?page={Int}
    private let baseUrl: String = "https://api.bookmate.com/api/"
    private let apiVersion = "v5/"
    private let objectString = "books/"
    private let popularString = "popular?"
    private let contentString = "https://bookmate.com/books/"
    
    func listRequest(page: Int) -> URLRequest? {
        let urlString: String = baseUrl + apiVersion + objectString + popularString  + "page=\(page)"
        if let url = URL(string: urlString) {
            return URLRequest(url: url)
        }
        return nil
    }
    func contentRequest(id: String) -> URLRequest? {
        // https://bookmate.com/books/{id}
        
        let urlString: String = contentString + id
        if let url = URL(string: urlString) {
            return URLRequest(url: url)
        }
        return nil
    }
}

