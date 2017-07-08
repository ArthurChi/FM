//
//  FMPlayer.swift
//  FMAudioPlayer
//
//  Created by cjfire on 2017/7/8.
//  Copyright © 2017年 cjfire. All rights reserved.
//

import Foundation
import AVFoundation

final class FMPlayer {
    
    static let `default` = FMPlayer()
    
    fileprivate var player: AVPlayer?
    
    fileprivate init() {}
    
    @discardableResult
    static func load(with urlStr: String) -> FMPlayer {
        let musicUrl = URL.init(string: urlStr)
        let playAsset = AVURLAsset.init(url: musicUrl!)
        let playItem = AVPlayerItem(asset: playAsset)
        self.default.player = AVPlayer.init(playerItem: playItem)
        return self.default
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
}
