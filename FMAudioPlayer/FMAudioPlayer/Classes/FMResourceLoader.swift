//
//  FMDataSourceLoader.swift
//  FMAudioPlayer
//
//  Created by cjfire on 2017/7/9.
//  Copyright © 2017年 cjfire. All rights reserved.
//

import Foundation
import AVFoundation

class FMResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
    
    fileprivate lazy var downloader = FMAudioDownloader()
    
    // 如果有本地缓存 -> 则向外界响应
    // 如果没有
    //      !正在下载 -> 下载
    //      需要重新下载
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        let url = loadingRequest.request.url
        
        if FMAudioFileManager.cacheFileExists(url: url?.httpURL()) {
            handleLoadingRequest(loadingRequest)
        } else if let url = url, downloader.loadedSize == 0 {
            
            let offset = loadingRequest.dataRequest?.requestedOffset ?? 0
            
            downloader.download(url: url.httpURL(), offset: offset)
        }
        
        return true
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        
        print("cancel")
    }
    
    fileprivate func handleLoadingRequest(_ loadingRequest: AVAssetResourceLoadingRequest) {
        let url = loadingRequest.request.url
        loadingRequest.contentInformationRequest?.contentLength = FMAudioFileManager.cacheFileSize(url: url)
        loadingRequest.contentInformationRequest?.contentType = "public.mp3"//FMAudioFileManager.contentType(url: url)
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        
        
        // TODO: 
//        let data = NSData.init(contentsOfFile: FMAudioFileManager.cacheFilePath(url: url))
        let data = try? NSData.init(contentsOfFile: FMAudioFileManager.cacheFilePath(url: url), options: .mappedIfSafe)
        
        guard let dataVaild = data, let dataRequestVaild = loadingRequest.dataRequest, dataVaild.length > 0, dataRequestVaild.requestedOffset >= 0, dataRequestVaild.requestedLength > 0 else {
            return
        }
        
        let subData = dataVaild.subdata(with: NSRange.init(location: Int(dataRequestVaild.currentOffset), length: dataRequestVaild.requestedLength))
        
        loadingRequest.dataRequest?.respond(with: subData)
        loadingRequest.finishLoading()
    }
}
