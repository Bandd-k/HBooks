//
//  DataDownloder.swift
//  HBooks
//
//  Created by Denis Karpenko on 09.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation

protocol IDataDownloder {
    weak var delegate: IMainModelDelegate? { get set }
    var noMoreBooks: Bool { get }
    func loadMore()
    func refresh()
    func downloadImage(with book: Book)
}

class DataDownloder: IDataDownloder {
    init (coreStack: CoreDataStack,)
    
}
