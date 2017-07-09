//
//  ViewController.swift
//  FMAudioPlayer
//
//  Created by cjfire on 2017/7/8.
//  Copyright © 2017年 cjfire. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var fmPlayer: FMPlayer?
    
    @IBOutlet weak var loadprogress: UIProgressView!
    
    
    @IBAction func play(_ sender: UIButton) {
        fmPlayer?.play()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        fmPlayer?.pause()
    }
    
    @IBAction func stop(_ sender: UIButton) {
        fmPlayer?.stop()
    }
    
    @IBAction func noSound(_ sender: UISwitch) {
        fmPlayer?.setMute(status: sender.isOn)
    }
    
    @IBAction func progress(_ sender: UISlider) {
        fmPlayer?.setProgress(progress: sender.value)
    }
    
    @IBAction func volume(_ sender: UISlider) {
        fmPlayer?.setVolume(volume: sender.value)
    }
    
    @IBAction func rate(_ sender: UIButton) {
        fmPlayer?.setRate(rate: 2)
    }
    
    @IBAction func back(_ sender: UIButton) {
        fmPlayer?.setSeekDiff(timeDiff: -5)
    }
    
    @IBAction func proceding(_ sender: UIButton) {
        fmPlayer?.setSeekDiff(timeDiff: 5)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let musicPath = "http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"
        fmPlayer = FMPlayer.shareInstance.load(with: musicPath)
    }
}

