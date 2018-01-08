//
//  IImageDownloaderService.swift
//  HBooks
//
//  Created by Denis Karpenko on 08.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit

protocol IImageDownloaderService {
    func downloadImage(with book: Book,completionHandler: @escaping (Result<UIImage>) -> Void)
    
}
    
class ImageDownloaderService: IImageDownloaderService {
    private var imageDownloadsInProgress: [String: ImageDownloader] = [:]
    
    deinit {
        // terminate all pending download connections
        self.terminateAllDownloads()
    }
    
    private func terminateAllDownloads() {
        // terminate all pending download connections
        let allDownloads = self.imageDownloadsInProgress.values
        for download in allDownloads {download.cancelDownload()}
        
        self.imageDownloadsInProgress.removeAll(keepingCapacity: false)
    }
    
    func downloadImage(with book: Book, completionHandler: @escaping (Result<UIImage>) -> Void) {
        let id = book.id!
        var imageDownloader = imageDownloadsInProgress[id]
        if imageDownloader == nil {
            imageDownloader = ImageDownloader(url: book.coverURL!)
            imageDownloadsInProgress[id] = imageDownloader
            imageDownloader!.startDownload(completionHandler: { (result) in
                self.imageDownloadsInProgress.removeValue(forKey: id)
                completionHandler(result)
            })
        }
    }

}
