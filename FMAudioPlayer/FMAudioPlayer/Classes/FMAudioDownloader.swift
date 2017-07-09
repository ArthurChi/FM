//
//  FMDownloader.swift
//  FMAudioPlayer
//
//  Created by cjfire on 2017/7/9.
//  Copyright © 2017年 cjfire. All rights reserved.
//

import Foundation

class FMAudioDownloader: NSObject {
    
    fileprivate var totalSize: Int64 = 0
    fileprivate var url: URL!
    var loadedSize: Int64 = 0
    
    fileprivate lazy var session: URLSession? = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
    fileprivate var outputStream: OutputStream?
    
    func download(url: URL, offset: Int64) {
//        cancelAndClean()
        
        self.url = url
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 0
        request.setValue("bytes=%lld-\(offset)", forHTTPHeaderField: "Range")
        
        let task = session?.dataTask(with: request)
        task?.resume()
    }
    
    func cancelAndClean() {
        session?.invalidateAndCancel()
        session = nil
        loadedSize = 0
    }
}

extension FMAudioDownloader: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        if let rep = response as? HTTPURLResponse {
            
            if let contentLength = rep.allHeaderFields["Content-Length"] as? String {
                totalSize = Int64(contentLength) ?? 0
            }
            
            if let contentRageStr = rep.allHeaderFields["Content-Range"] as? String {
                totalSize = Int64(contentRageStr) ?? 0
            }
        }
        
        outputStream = OutputStream.init(toFileAtPath: FMAudioFileManager.tmpFilePath(url: self.url), append: true)
        outputStream?.open()
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        loadedSize += data.count
        let _ = data.withUnsafeBytes { outputStream?.write($0, maxLength: data.count) }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error == nil {
            if totalSize == FMAudioFileManager.tmpFileSize(url: self.url) {
                FMAudioFileManager.moveFileToCache(url: self.url)
            }
        }
        
        outputStream?.close()
    }
}
