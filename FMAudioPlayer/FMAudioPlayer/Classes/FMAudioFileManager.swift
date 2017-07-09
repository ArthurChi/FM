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
    
    static func cacheFilePath(url: URL?) -> String {
        if let url = url {
            return (cachePath as NSString).appendingPathComponent(url.lastPathComponent)
        }
        
        return ""
    }
    
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
    
    static func cacheFileSize(url: URL?) -> Int64 {
        guard let urlVaild = url else { return 0 }
        guard cacheFileExists(url: url) else { return 0 }
        
        do {
            let size = try FileManager.default.attributesOfItem(atPath: cacheFilePath(url: urlVaild))[FileAttributeKey.size] as? NSNumber
            
            return size?.int64Value ?? 0
        } catch {
            return 0
        }
    }
    
    static func contentType(url: URL?) -> String {
        guard let urlVaild = url else { return "" }
        guard cacheFileExists(url: url) else { return "" }
        
        let fileExtension = cacheFilePath(url: urlVaild)
        
        let contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        
        let result = contentTypeCF?.takeRetainedValue() as String? ?? ""
        return result
    }
}
