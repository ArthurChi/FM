//
//  URL+Extension.swift
//  FMAudioPlayer
//
//  Created by cjfire on 2017/7/8.
//  Copyright © 2017年 cjfire. All rights reserved.
//

import Foundation

extension URL {
    
    public init(safeString: String) {
        guard let instance = URL(string: safeString) else {
            fatalError("\(safeString) unconstruct to URL")
        }
        
        self = instance
    }
    
    public func streamURL() -> URL {
        return changeScheme(to: "stream")
    }
    
    public func httpURL() -> URL {
        return changeScheme(to: "http")
    }
    
    private func changeScheme(to changedSceme: String) -> URL {
        var components = URLComponents(string: self.absoluteString)
        components?.scheme = changedSceme
        
        if let url = components?.url {
            return url
        } else {
            fatalError()
        }
    }
}
