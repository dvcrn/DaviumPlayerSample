//
//  DaviumPlayerManager.swift
//  davium
//
//  Created by kawase yu on 2017/01/01.
//  Copyright © 2017年 Davium inc. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

protocol DaviumPlayerManagerDelegate:class{
    func onLoadProgress(progress:CGFloat)
    func onPlayerProgress(current:Int, duration:Int)
    func onPlayerFadeout()
}

class DaviumPlayerManager: NSObject {

    /* ▼ Singleton */
    static private var instance:DaviumPlayerManager?
    
    static func sharedInstance()->DaviumPlayerManager{
        if let result = instance{
            return result
        }
        
        let result = DaviumPlayerManager()
        instance = result
        
        return result
    }
    
    private override init(){}
    
    /* ▼ cache */
    
    private var cacheList:[String:Data] = [:]
    private func cacheData(previewUrl:String)->Data?{
        return cacheList[previewUrl]
    }
    private func putCacheData(previewUrl:String, data:Data){
        cacheList[previewUrl] = data
    }
    
    /* ▼ implements */
    
    private let FADE_TIME:CGFloat = 5.0
    private var player:AVAudioPlayer?
    private var progressTimer:Timer?
    
    private func startTimer(){
        stopTimer()
        progressTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(DaviumPlayerManager.onProgressTime), userInfo: nil, repeats: true)
    }
    
    private func stopTimer(){
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private dynamic func onProgressTime(){
        
        guard let player = player else{
            print("onProgressTime no player")
            return
        }
        
        // checkTime
        
        let currentTime = Int(player.currentTime)
        let duration = Int(player.duration)
        delegate?.onPlayerProgress(current: currentTime, duration: duration)
        print("onProgressTime \(currentTime) / \(duration)")
        
        if currentTime >= duration - Int(FADE_TIME){
            stopTimer()
            fadeOut()
        }
    }
    
    private func fadeOut(){
        
        guard let player = player else{
            return;
        }
        
        print("fadeOut")
        
        delegate?.onPlayerFadeout()
        
        AloeChain().add(Double(FADE_TIME), ease: .Ease) { (val) in
            let reverse:CGFloat = 1 - val
            player.volume = Float(reverse)
        }.call {
            print("end fadeout")
        }.execute()
    }
    
    private func donwloadAndPlay(previewUrl:String){
        print("donwloadAndPlay \(previewUrl)")
        // get audioData
        Alamofire.request(previewUrl, method: .get).responseData { (response) in
            
            // check result
            if !response.result.isSuccess{
                print("fail connect")
                return;
            }
            
            // get data from response
            guard let data = response.result.value else{
                print("fail data")
                return
            }
            
            print("success donwload")
            // try play sound
            do{
                self.player = try AVAudioPlayer(data: data)
                self.putCacheData(previewUrl: previewUrl, data:data)
                self.player!.play()
                print("played")
            }catch let error{
                print("invalid audio data")
                print(error)
            }
            }.downloadProgress(closure: { (progress) in
                // p → 0.0 〜 1.0
                let p = CGFloat(progress.fractionCompleted)
                print("progress:\(p)")
                self.delegate?.onLoadProgress(progress: p)
            })
    }
    
    private func play(data:Data){
        // try play sound
        do{
            player = try AVAudioPlayer(data: data)
            player!.play()
        }catch let error{
            print("invalid audio data")
            print(error)
        }
    }
    
    /* ▼ public */
    
    var delegate:DaviumPlayerManagerDelegate?
    
    public func playAudio(previewUrl:String){
        
        startTimer()
        
        print("playAudio")
        // hasCache
        if let data = cacheData(previewUrl: previewUrl){
            print("has cache")
            play(data: data)
            return;
        }
        
        // no cache
        print("no cache")
        donwloadAndPlay(previewUrl: previewUrl)
    }
    
}
