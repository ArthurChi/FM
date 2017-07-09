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
    var status: PlayerStatus = .unknow
    
    fileprivate override init() {
        super.init()
    }
    
    @discardableResult
    func load(with urlStr: String) -> FMPlayer {
        
        if let player = player {
            if let playItem = player.currentItem {
                playItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
                playItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
            }
        }
        
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
                    self.status = .failue
                }
            }
        } else if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) {
            if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                if status.boolValue {
                    print("当前资源, 准备的已经足够播放了")
                } else {
                    print("资源不够")
                    self.status = .failue
                }
            }
        }
    }
    
    var totalSec: TimeInterval {
        if let player = player {
            if let currentItem = player.currentItem {
                
                let totalTime = currentItem.duration
                if !totalTime.flags.contains(.valid) {
                    return CMTimeGetSeconds(totalTime)
                }
            }
        }
        
        return 0
    }
    
    var currentSec: TimeInterval {
        if let player = player {
            if let currentItem = player.currentItem {
                let currentTime = currentItem.currentTime()
                return CMTimeGetSeconds(currentTime)
            }
        }
        
        return 0
    }
    
    // MARK: - input functions
    func play() {
        self.status = .playing
        self.player?.play()
    }
    
    func pause() {
        self.status = .pause
        self.player?.pause()
    }
    
    func stop() {
        self.status = .stop
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
        
        if progress < 0 || progress > 1 { return }
        
        let toPlaySec = TimeInterval(progress) * totalSec
        
        seekToPlaySec(time: toPlaySec)
    }
    
    func setSeekDiff(timeDiff: TimeInterval) {
        
        let toPlaySec = timeDiff + currentSec
        
        if toPlaySec < 0 || toPlaySec > totalSec { return }
        
        seekToPlaySec(time: toPlaySec)
    }
    
    private func seekToPlaySec(time: TimeInterval) {
        
        if let player = player {
            if let playItem = player.currentItem {
                if playItem.status == .readyToPlay {
                    
                    let toPlayTime = CMTimeMake(Int64(time), 1)
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
    }
    
    // MARK: - 输出接口
    func totalTimeFormat() -> String {
        let result = String(format: "%02zd分%02zd秒", totalSec / 60, totalSec.truncatingRemainder(dividingBy: 60))
        return result
    }
    
    func currentTimeFormat() -> String {
        let result = String(format: "%02zd分%02zd秒", currentSec / 60, currentSec.truncatingRemainder(dividingBy: 60))
        return result
    }
    
    func mute() -> Bool {
        return player?.isMuted ?? false
    }
    
    func procress() -> Float {
        if totalSec == 0 { return 0 }
        return Float(currentSec / totalSec)
    }
    
    func volume() -> Float {
        return player?.volume ?? 0
    }
    
    // MARK: - 状态
    enum PlayerStatus {
        case unknow
        case loading
        case playing
        case pause
        case stop
        case failue
    }
}

extension FMPlayer: AVAssetResourceLoaderDelegate {
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        print(loadingRequest)
        self.status = .loading
        
        return true
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        
        print("cancel")
    }
}
