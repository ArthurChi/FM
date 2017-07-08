//
//  FMPlayer.swift
//  FMAudioPlayer
//
//  Created by cjfire on 2017/7/8.
//  Copyright © 2017年 cjfire. All rights reserved.
//

import Foundation
import AVFoundation

final class FMPlayer: NSObject {
    
    static var shareInstance = FMPlayer()
    fileprivate var player: AVPlayer?
    
    fileprivate override init() {
        super.init()
    }
    
    @discardableResult
    func load(with urlStr: String) -> FMPlayer {
        let musicUrl = URL.init(safeString: urlStr)
        let playAsset = AVURLAsset.init(url: musicUrl.streamURL())
        
        playAsset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        
        let playItem = AVPlayerItem(asset: playAsset)
        playItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions.new, context: nil)
        playItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: NSKeyValueObservingOptions.new, context: nil)
        
        self.player = AVPlayer.init(playerItem: playItem)
        return self
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            
            if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                if AVPlayerItemStatus.readyToPlay.rawValue == status.intValue {
                    print("准备好播放, 这时候播放没问题")
                } else {
                    print("没有准备好")
                }
            }
        } else if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) {
            if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                if status.boolValue {
                    print("当前资源, 准备的已经足够播放了")
                } else {
                    print("资源不够")
                }
            }
        }
    }
    
    // MARK: - input functions
    func play() {
        self.player?.play()
    }
    
    func pause() {
        self.player?.pause()
    }
    
    func stop() {
        self.pause()
        self.player = nil
    }
    
    func setMute(status: Bool) {
        self.player?.isMuted = status
    }
    
    func setVolume(volume: Float) {
        self.player?.volume = volume
    }
    
    func setRate(rate: Float) {
        self.player?.rate = rate
    }
    
    func setProgress(progress: Float) {
        
        if let player = player {
            if let currentItem = player.currentItem {
                
                let totalTime = currentItem.duration
                let totalSec = CMTimeGetSeconds(totalTime)
                let toPlaySec = progress * Float(totalSec)
                let toPlayTime = CMTimeMake(Int64(toPlaySec), 1)
                
                player.seek(to: toPlayTime, completionHandler: { (finished) in
                    if finished {
                        print("确认加载")
                    } else {
                        print("取消加载")
                    }
                })
            }
        }
    }
    
    // MARK: - 输出接口
    
}

extension FMPlayer: AVAssetResourceLoaderDelegate {
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        print(loadingRequest)
        
        return true
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        
        print("cancel")
    }
}
