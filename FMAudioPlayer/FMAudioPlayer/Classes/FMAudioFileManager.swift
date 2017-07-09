//
//  FMAudioFileManager.swift
//  FMAudioPlayer
//
//  Created by cjfire on 2017/7/9.
//  Copyright © 2017年 cjfire. All rights reserved.
//

import Foundation
import MobileCoreServices

fileprivate enum FileType {
    case cache
    case tmp
}

struct FMAudioFileManager {
    
    fileprivate static let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
    fileprivate static let tmpPath = NSTemporaryDirectory()
    
    static func contentType(url: URL?) -> String {
        guard let urlVaild = url else { return "" }
        guard cacheFileExists(url: url) else { return "" }
        
        let fileExtension = cacheFilePath(url: urlVaild)
        
        let contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        
        let result = contentTypeCF?.takeRetainedValue() as String? ?? ""
        return result
    }
    
    static func moveFileToCache(url: URL?) {
        guard let urlVaild = url else {
            return
        }
        
        try? FileManager.default.moveItem(atPath: tmpFilePath(url: urlVaild), toPath: cacheFilePath(url: urlVaild))
    }
    
    static func cleanTmp(url: URL?) {
        try? FileManager.default.removeItem(atPath: tmpFilePath(url: url))
    }
}

extension FMAudioFileManager { // filePath
    
    static func cacheFilePath(url: URL?) -> String {
        return filePath(url: url, type: .cache)
    }
    
    static func tmpFilePath(url: URL?) -> String {
        return filePath(url: url, type: .tmp)
    }
    
    fileprivate static func filePath(url: URL?, type: FileType) -> String {
        
        var rootPath: String
        
        switch type {
        case .cache:
            rootPath = cachePath
        case .tmp:
            rootPath = tmpPath
        }
        
        if let url = url {
            return (rootPath as NSString).appendingPathComponent(url.lastPathComponent)
        }
        
        return ""
    }
}

extension FMAudioFileManager { // file exist
    
    static func cacheFileExists(url: URL?) -> Bool {
        if let url = url {
            return self.filExists(type: .cache, url: url)
        }
        return false
    }
    
    static func tmpFileExists(url: URL?) -> Bool {
        if let url = url {
            return self.filExists(type: .tmp, url: url)
        }
        return false
    }
    
    fileprivate static func filExists(type: FileType, url: URL) -> Bool {
        
        switch type {
        case .cache:
            if cachePath.isEmpty {
                return false
            } else {
                return FileManager.default.fileExists(atPath: cacheFilePath(url: url))
            }
        case.tmp:
            break
        }
        
        return true
    }
}

extension FMAudioFileManager {
    
    static func cacheFileSize(url: URL?) -> Int64 {
        return fileSize(url: url, type: .cache)
    }
    
    static func tmpFileSize(url: URL?) -> Int64 {
        return fileSize(url: url, type: .tmp)
    }
    
    fileprivate static func fileSize(url: URL?, type: FileType) -> Int64 {
        guard let urlVaild = url else { return 0 }
        guard cacheFileExists(url: url) else { return 0 }
        
        var rootPath: String
        
        switch type {
        case .cache:
            rootPath = cacheFilePath(url: urlVaild)
        case .tmp:
            rootPath = tmpFilePath(url: urlVaild)
        }
        
        do {
            let size = try FileManager.default.attributesOfItem(atPath: rootPath)[FileAttributeKey.size] as? NSNumber
            
            return size?.int64Value ?? 0
        } catch {
            return 0
        }
    }
}
