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
    
    @IBOutlet weak var loadprogress: UIProgressView!
    
    
    @IBAction func play(_ sender: UIButton) {
        FMPlayer.default.play()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        FMPlayer.default.pause()
    }
    
    @IBAction func stop(_ sender: UIButton) {
        FMPlayer.default.stop()
    }
    
    @IBAction func noSound(_ sender: UISwitch) {
        FMPlayer.default.setMute(status: sender.isOn)
    }
    
    @IBAction func progress(_ sender: UISlider) {
        FMPlayer.default.setProgress(progress: sender.value)
    }
    
    @IBAction func volume(_ sender: UISlider) {
        FMPlayer.default.setVolume(volume: sender.value)
    }
    
    @IBAction func rate(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let musicPath = "http://127.0.0.1/app/The_Black_Swan.mp3"
        FMPlayer.load(with: musicPath)
    }
}

