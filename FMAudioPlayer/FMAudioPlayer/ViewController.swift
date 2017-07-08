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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // "http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"
        let musicPath = "http://192.168.1.4:2000"
        fmPlayer = FMPlayer.shareInstance.load(with: musicPath)
    }
}

