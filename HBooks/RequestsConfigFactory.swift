//
//  RequestsConfigFactory.swift
//  HBooks
//
//  Created by Denis Karpenko on 03.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation

struct RequestsConfigFactory {
    static func listConfig(page: Int) -> RequestConfig<[BooksApiModel]> {
        let request = RequestMaker().listRequest(page: page)
        return RequestConfig<[BooksApiModel]>(request:request, parser: ListParser())
    }
}
