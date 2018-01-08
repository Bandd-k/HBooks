//
//  RequestSender.swift
//  HBooks
//
//  Created by Denis Karpenko on 03.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation

class RequestSender: IRequestSender {
    
    private let session = URLSession.shared // maybe change on default session!
    func send<T>(config: RequestConfig<T>, completionHandler: @escaping (Result<T>) -> Void) {
        
        guard let urlRequest = config.request else {
            completionHandler(Result.Fail("url string can't be parser to URL"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.Fail(error.localizedDescription))
                return
            }
            guard let data = data,
                let parsedModel: T = config.parser.parse(data: data) else {
                    completionHandler(Result.Fail("recieved data can't be parsed"))
                    return
            }
            completionHandler(Result.Success(parsedModel))
        }
        
        task.resume()
    }
}

