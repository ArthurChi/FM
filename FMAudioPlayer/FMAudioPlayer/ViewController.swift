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
    
    private var player: AVPlayer!
    @IBOutlet weak var loadprogress: UIProgressView!
    
    
    @IBAction func play(_ sender: UIButton) {
        self.player.play()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        self.player.pause()
    }
    
    @IBAction func stop(_ sender: UIButton) {
        
    }
    
    @IBAction func noSound(_ sender: UISwitch) {
    }
    
    @IBAction func progress(_ sender: UISlider) {
    }
    
    @IBAction func volume(_ sender: UISlider) {
    }
    
    @IBAction func rate(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let musicPath = "http://127.0.0.1/app/The_Black_Swan.mp3"
        let musicUrl = URL.init(string: musicPath)
        let playAsset = AVURLAsset.init(url: musicUrl!)
        let playItem = AVPlayerItem(asset: playAsset)
        self.player = AVPlayer.init(playerItem: playItem)
    }
}

