//
//  ACVideoPlayer.swift
//  TestAVPlayer
//
//  Created by Husam Aamer on 3/24/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GoogleCast
extension CVideoView:CVideoProgressViewDelegate {
    func progressChangingIsAllowed() -> Bool {
        if ChiefsPlayer.shared.isCastingTo == .chromecast {
            return CChromecastRemoteControlFunctions.canChangeProgress
        }
        return !ChiefsPlayer.shared.isPlayerError
    }
    
    
    func progressChanged(to percent: CGFloat) {
        
        //For chromecast
        if ChiefsPlayer.shared.isCastingTo == .chromecast {
            if let duration = GCKCastContext.sharedInstance()
                .sessionManager
                .currentCastSession?
                .remoteMediaClient?
                .mediaStatus?
                .mediaInformation?
                .streamDuration {
                CChromecastRemoteControlFunctions.seek(to: TimeInterval(percent * CGFloat(duration)))
            }
            return
        }
        
        //For AVPlayer
        var playerDuration : TimeInterval!
        if let duration = AVCGlobalFuncs.playerItemDuration() {
            playerDuration = duration
        } else {
            //If duration is unknown then set current time as duration
            playerDuration = CMTimeGetSeconds(ChiefsPlayer.shared.player.currentTime())
        }
        var duration = CGFloat(playerDuration)
        if duration.isNaN || duration.isInfinite {duration = 0} //Happens when user is on error only
        let targetTime = duration * percent
        var  selectedTime = CMTime(seconds: Double(targetTime), preferredTimescale: 1000)
        if ShoofAPI.Settings.shared.isFamilyModOn {
            if let currentTime = ChiefsPlayer.shared.selectedSource.timelines?.first(where: { targetTime >= $0.startTime && targetTime < $0.endTime }) {
                print(currentTime)
                selectedTime = CMTime(seconds: Double(currentTime.endTime), preferredTimescale: 1000)
            }
        }
        ChiefsPlayer.shared.player.seek(to: selectedTime)
        
        return
    }
}
