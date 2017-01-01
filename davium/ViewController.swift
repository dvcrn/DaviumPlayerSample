//
//  ViewController.swift
//  davium
//
//  Created by kawase yu on 2017/01/01.
//  Copyright © 2017年 Davium inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DaviumPlayerManagerDelegate {
    
    private static let BarWidth:CGFloat = 300

    private let bar = UIView(frame: CGRect(x: 0, y: 0, width: ViewController.BarWidth, height: 5))
    private let msg = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        bar.center = view.center
        let disableBar = UIView(frame: bar.frame)
        disableBar.backgroundColor = UIColor.gray
        view.addSubview(disableBar)
        view.addSubview(bar)
        
        msg.frame.origin = bar.frame.origin
        msg.frame = bar.frame
        msg.frame.origin.y += 5
        msg.frame.size.height = 50
        msg.textAlignment = .center
        msg.text = "Message"
        view.addSubview(msg)
        
        
        // initial
        onLoadProgress(progress: 0)
        
        // play
       playAudio()
    }
    
    private func playAudio(){
        // play
        let daviumPlayerManger = DaviumPlayerManager.sharedInstance()
        daviumPlayerManger.delegate = self
        let audioPreviewUrl = "http://a744.phobos.apple.com/us/r20/Music/v4/2f/53/63/2f536341-4614-7453-1275-d68fdc0df2e2/mzaf_7461742241849893593.aac.m4a"
        daviumPlayerManger.playAudio(previewUrl: audioPreviewUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: DaviumPlayerManagerDelegate
    
    func onLoadProgress(progress:CGFloat){
        print("progress:\(progress)")
        msg.text = "progress:\(Int(progress*100))"
        bar.frame.size.width = ViewController.BarWidth * progress
        bar.backgroundColor = UIColor.orange
        
        if progress == 1.0{
            msg.text = "playing"
        }
    }
    
    func onPlayerProgress(current: Int, duration: Int) {
        bar.backgroundColor = UIColor.blue
        let progress = CGFloat(current) / CGFloat(duration)
        bar.frame.size.width = ViewController.BarWidth * progress
        
        msg.text = "\(current) / \(duration)"
    }
    
    func onPlayerFadeout() {
        msg.text = "fadeout"
    }
    
}

