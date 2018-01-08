//
//  ImageDownloader.swift
//  HBooks
//
//  Created by Denis Karpenko on 08.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader {
    
    
    private var sessionTask: URLSessionDataTask?
    private let url: String

    init(url: String) {
        self.url = url
    }
    
    func startDownload(completionHandler: @escaping (Result<UIImage>) -> Void) {
        let request = URLRequest(url: URL(string: url)!) //  make safe later
        
        // create an session data task to obtain and download the app icon
        sessionTask = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            // in case we want to know the response status code
            //let httpStatusCode = (response as! HTTPURLResponse).statusCode
            
            if let actualError = error as NSError? {
                completionHandler(Result.Fail(actualError.localizedDescription))
                return
            }
            if let actualImage = UIImage(data: data!) {
                completionHandler(Result.Success(actualImage))
                return
            }
            completionHandler(Result.Fail("Some Problem with image"))
        })
        
        self.sessionTask?.resume()
    }
    
    func cancelDownload() {
        self.sessionTask?.cancel()
        sessionTask = nil
    }
}
