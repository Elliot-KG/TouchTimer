//
//  Timer.swift
//  Touch Timer
//
//  Created by Elliot Goldman on 6/16/15.
//  Copyright (c) 2015 com.ElliotKGoldman. All rights reserved.
//

import Foundation


protocol TimerDelegate{
    func timerEnded()
    func updateTime(hours : Int, minutes : Int, seconds : Int)
}

class Timer{
    
    let time : NSDate //The time the timer will end if it's a timer or the time the stopwatch started
    var timer : NSTimer!
    let delegate : TimerDelegate
    let isStopWatch : Bool

    //init for standard timer
    convenience init(times : (hours : Int, minutes : Int, seconds : Int), delegate : TimerDelegate){
        let startTime = NSDate()
        let hours = times.hours
        let minutes = times.minutes
        let seconds = times.seconds
        let time = startTime.dateByAddingTimeInterval(Double(seconds + (minutes * 60) + (hours * 60 * 60)))
        self.init(time: time, delegate: delegate, stopwatch : false)
    }
    
    //init with seconds to count down from
    init(time : NSDate, delegate : TimerDelegate, stopwatch : Bool){
        let startTime = NSDate()
        self.time = time
        self.delegate = delegate
        
        let timeInterval = time.timeIntervalSinceNow
        self.isStopWatch = stopwatch
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "checkTimer:", userInfo: nil, repeats: true)
    }
    
    //init for stopwatch
    init(delegate : TimerDelegate){
        self.isStopWatch = true
        self.time = NSDate()
        self.delegate = delegate
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "checkTimer:", userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        timer.invalidate()
    }
    
    @objc func checkTimer(timer : NSTimer){

        var elapsedSeconds : Int = Int(time.timeIntervalSinceNow)
        //If the time has passed 0 and it's not a stopwatch
        if((elapsedSeconds <= 0) && !isStopWatch ){
            endTimer()
        }else{
            elapsedSeconds = abs(elapsedSeconds)
            //Absolute value ["abs()"] because if stop watch it will always be negative
            let hours : Int = (elapsedSeconds / (60*60))
            elapsedSeconds = (elapsedSeconds - (hours * 60 * 60))
            let minutes : Int = (elapsedSeconds / 60)
            elapsedSeconds = (elapsedSeconds - (minutes * 60))
            let seconds : Int = elapsedSeconds
            delegate.updateTime(hours, minutes: minutes, seconds: seconds)
        }

    }
    
    func endTimer(){
        timer.invalidate()
        delegate.timerEnded()
    }
    
}
