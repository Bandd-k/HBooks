//
//  String+decodedFromHtml.swift
//  HBooks
//
//  Created by Denis Karpenko on 04.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation

extension String {
    func decodedFromHtml() -> String? {
        guard let data = data(using: .unicode) else { return nil }
        let decodedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html],
                                                    documentAttributes: nil).string
        return decodedString
    }
}
