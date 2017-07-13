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
    
    fileprivate lazy var requests = Array<AVAssetResourceLoadingRequest>()
    fileprivate lazy var downloader: FMAudioDownloader = {
        let downloader = FMAudioDownloader()
        downloader.delegate = self
        return downloader
    }()
    
    fileprivate let bufferSize: Int64 = 600
    
    // 如果有本地缓存 -> 则向外界响应
    // 如果没有
    //      !正在下载 -> 下载
    //      需要重新下载
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let url = loadingRequest.request.url?.httpURL() else { return false }
        
        var requestOffset = loadingRequest.dataRequest?.requestedOffset ?? 0
        let currentOffset = loadingRequest.dataRequest?.currentOffset ?? 0
        
        if requestOffset != currentOffset {
            requestOffset = currentOffset
        }
        
        // 文件是否存在
        if FMAudioFileManager.cacheFileExists(url: url) {
            handleLoadingRequest(loadingRequest)
            return true
        }
        
        requests.append(loadingRequest)
        
        // 是否正在下载
        if downloader.loadedSize == 0 {
            downloader.download(url: url, offset: requestOffset)
            return true
        }
        
        // 是否重新下载
        if(requestOffset < downloader.requestOffset || requestOffset > downloader.requestOffset + downloader.loadedSize + bufferSize) {
            downloader.download(url: url, offset: requestOffset)
            return true
        }
        
        // 开始处理资源请求
//        handleAllLoadingRequest()
        return true
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) { // cancel
        
        if let index = requests.index(of: loadingRequest) {
            requests.remove(at: index)
        }
    }
    
    fileprivate func handleLoadingRequest(_ loadingRequest: AVAssetResourceLoadingRequest) {
        let url = loadingRequest.request.url
        loadingRequest.contentInformationRequest?.contentLength = FMAudioFileManager.cacheFileSize(url: url)
        loadingRequest.contentInformationRequest?.contentType = FMAudioFileManager.contentType(url: url)
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
    
    fileprivate func handleAllLoadingRequest() {
        
        for loadingRequest in requests {
            // 填充信息头
            let url = loadingRequest.request.url
            loadingRequest.contentInformationRequest?.contentLength = downloader.totalSize
            loadingRequest.contentInformationRequest?.contentType = downloader.contentType
            loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
            
            // 填充数据
            var requestLength: Int = 0
            var responseLength: Int = 0
            
            if let data = try? NSData.init(contentsOfFile: FMAudioFileManager.tmpFilePath(url: url), options: NSData.ReadingOptions.mappedIfSafe) {
                
                let requestOffset = loadingRequest.dataRequest?.requestedOffset ?? 0
                requestLength = loadingRequest.dataRequest?.requestedLength ?? 0
                
                let responseOffset = requestOffset - self.downloader.requestOffset
                responseLength = min((downloader.requestOffset + downloader.totalSize - requestOffset), requestLength)
                
                let subData = data.subdata(with: NSMakeRange(Int(responseOffset), Int(responseLength)))
                
                
                loadingRequest.dataRequest?.respond(with: subData)
            }
            
            // 完成请求
            
            if requestLength == responseLength && requestLength != 0 && responseLength != 0 {
                loadingRequest.finishLoading()
            }
            
            if let index = requests.index(of: loadingRequest) {
                requests.remove(at: index)
            }
        }
        
    }
}

extension FMResourceLoader: FMAudioDownLoaderDelegate {
    
    func downloading() {
        handleAllLoadingRequest()
    }
}
