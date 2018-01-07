//
//  IRequestSender.swift
//  HBooks
//
//  Created by Denis Karpenko on 03.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation

struct RequestConfig<T> {
    let request: URLRequest?
    let parser: Parser<T>
}

enum Result<T> {
    case Success(T)
    case Fail(String)
}

protocol IRequestSender {
    func send<T>(config: RequestConfig<T>, completionHandler: @escaping (Result<T>) -> Void)
}


