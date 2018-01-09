//
//  ListParser.swift
//  HBooks
//
//  Created by Denis Karpenko on 03.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation

class Parser<T> {
    func parse(data: Data) -> T? { return nil }
}

struct BooksApiModel {
    let id: String
    let title: String
    let annotation: String
    let authors: String
    let coverURL: String
    let placeholder: Data?
}

class ListParser: Parser<[BooksApiModel]> {
    override func parse(data: Data) -> [BooksApiModel]? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                return nil
            }
            
            guard let rawBooks = json["books"] as? [[String : Any]] else {
                return nil
            }
            var parsedBooks = [BooksApiModel]()
            for entry in rawBooks {
                guard let entryTitle = entry["title"] as? String,
                    let entryId = entry["uuid"] as? String,
                    var entryAnnotation = entry["annotation"] as? String,
                    let entryAuthors = entry["authors"] as? String,
                    let entryCoverDict = (entry["cover"] as? [String : Any]),
                    let entryCoverString = entryCoverDict["placeholder"] as? String,
                    let entryCoverData = Data(base64Encoded: entryCoverString),
                    let entrySmallImageURL = entryCoverDict["small"] as? String
                    else { continue }
                entryAnnotation = entryAnnotation.decodedFromHtml() ?? entryAnnotation
                entryAnnotation = entryAnnotation.trimmingCharacters(in: .whitespacesAndNewlines)
                parsedBooks.append(BooksApiModel(id: entryId, title: entryTitle, annotation: entryAnnotation, authors: entryAuthors, coverURL: entrySmallImageURL, placeholder: entryCoverData))
            }
            return parsedBooks
            
        } catch {
            print("error trying to convert data to JSON")
            return nil
        }
    }
}
