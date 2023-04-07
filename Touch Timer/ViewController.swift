//
//  ViewController.swift
//  Touch Timer
//
//  Created by Elliot Goldman on 6/16/15.
//  Copyright (c) 2015 com.ElliotKGoldman. All rights reserved.
//

//TODO: tutorial screen

import UIKit
import AudioToolbox
import AVFoundation

enum Slot {
    case hours
    case minutes
    case seconds
}

class ViewController: UIViewController, TimerDelegate {
    
    //Data elements
    var timer : Timer?
    //To keep track of what "slot" the user is currently editing
    private var slot = Slot.hours
    //for fading current slot
    private var fadeTimer = NSTimer()
    private var player : AVAudioPlayer?
    //Whether or not it's the first time running the app
    private var tutorial = false
    private static let FADETIMEDURATION = 0.6
    private static let SIDEFADETIMEDURATIONIN = 0.3
    private static let SIDEFADETIMEDURATIONOUT = 2.0
    private static let RESIZETIMEDURATION = 1.0
    
    //UIElements
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var seperatorLabelOne: UILabel!
    @IBOutlet weak var seperatorLabelTwo: UILabel!
    //Outer Labels
    @IBOutlet weak var labelUp: UIImageView!
    @IBOutlet weak var labelUpStart: UILabel!
    @IBOutlet weak var labelDown: UIImageView!
    @IBOutlet weak var labelDownStop: UILabel!
    @IBOutlet weak var labelRight: UIImageView!
    @IBOutlet weak var labelRightAll: UILabel!
    @IBOutlet weak var labelLeft: UIImageView!
    @IBOutlet weak var labelLeftSlot: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register notifications settings
        var types : UIUserNotificationType = UIUserNotificationType.Sound | UIUserNotificationType.Alert;
        
        var mySettings : UIUserNotificationSettings =
        UIUserNotificationSettings(forTypes:types, categories:nil);
        
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings);
        
        //Only start the fade timer if the timer isn't running
        if(timer == nil){
            fadeTimer = getFadeTimer()
        }
        
        //Setup audio playback
        var error: NSError?
        var success = AVAudioSession.sharedInstance().setCategory(
            AVAudioSessionCategoryPlayback,
            withOptions: .DefaultToSpeaker, error: &error)
        if !success {
            NSLog("Failed to set audio session category.  Error: \(error)")
        }
        
        
        //Hide side labels
        labelUp.alpha = 0
        labelUpStart.alpha = 0
        labelDown.alpha = 0
        labelDownStop.alpha = 0
        labelRight.alpha = 0
        labelRightAll.alpha = 0
        labelLeft.alpha = 0
        labelLeftSlot.alpha = 0
        
        //Shrink number labels so they can expand in
        hoursLabel.transform = CGAffineTransformMakeScale(0.0, 0.0)
        minutesLabel.transform = CGAffineTransformMakeScale(0.0, 0.0)
        secondsLabel.transform = CGAffineTransformMakeScale(0.0, 0.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        resizeIn(hoursLabel)
        resizeIn(minutesLabel)
        resizeIn(secondsLabel)
        if(tutorial){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tutorialVC = storyboard.instantiateViewControllerWithIdentifier("TutorialView") as! TutorialViewController
            
            self.presentViewController(tutorialVC, animated: true, completion:{
                //Make tutorial false because it was just shown
                self.tutorial = false
            })
        }
    }
    
    
    func initWithSaveState(date : NSDate, isStopwatch : Bool){
        timer = Timer(time: date, delegate: self, stopwatch: isStopwatch)
        //stop fader
        fadeTimer.invalidate()
    }
    
   func runTutorial(){
        tutorial = true
    }
    
//MARK: - UI Invoked Methods
    
    //Add one to whatever is being edited
    @IBAction func screenTapped(sender: UITapGestureRecognizer) {
        //If timer is currently "ended"
        if((player?.playing) != nil){
            self.resetAfterDone()
        }else if(timer==nil){//Only if a timer isn't running
            var time = currentSlot().text!.toInt()!
            time++
            currentSlot().text = ifOneDigitAddZero(String(time))
            currentSlot().alpha = 1
            overageCheck()
        }
    }
    
    
    //Switch to next slot (ie minutes -> seconds, etc)
    @IBAction func screenLongPressed(sender: UILongPressGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Began){
            //If timer is currently "ended"
            if((player?.playing) != nil){
                self.resetAfterDone()
            }else if(timer == nil){//Only if a timer isn't running
                //Reset current slot alpha to 1
                currentSlot().alpha = 1
                switch slot{
                case .hours:
                    slot = .minutes
                case .minutes:
                    slot = .seconds
                case .seconds:
                    slot = .hours
                }
                currentSlot().alpha = 0
            }
        }
    }
    
    //Reset all
    @IBAction func screenSwipedRight(sender: UISwipeGestureRecognizer) {
        //If timer is currently "ended"
        if((player?.playing) != nil){
            self.resetAfterDone()
        }else if(timer == nil){ //Only reset if a timer isn't running
            hoursLabel.text = "00"
            minutesLabel.text = "00"
            secondsLabel.text = "00"
            
            //Fade in and out label
            fadeSideLabel(labelRight)
            fadeSideLabel(labelRightAll)
        }

    }
    
    //Reset current slot
    @IBAction func screenSwipedLeft(sender: UISwipeGestureRecognizer) {
        //If timer is currently "ended"
        if((player?.playing) != nil){
            self.resetAfterDone()
        }else if(timer == nil){//Only reset if a timer isn't running
            currentSlot().text = "00"
        }
        //Fade in and out label
        fadeSideLabel(labelLeft)
        fadeSideLabel(labelLeftSlot)
    }
    
    //Start timer
    @IBAction func screenSwipedUp(sender: UISwipeGestureRecognizer) {
        if((player?.playing) != nil){ //If timer is currently "ended"
                self.resetAfterDone()
        }else if (timer != nil){
            //already started, just return
            return
        }else{
            let hours = hoursLabel.text!.toInt()!
            let minutes = minutesLabel.text!.toInt()!
            let seconds = secondsLabel.text!.toInt()!
            let totalSeconds = seconds + (minutes * 60) + (hours * 60 * 60)
            
            if(totalSeconds == 0){
                //Start count up timer
                timer = Timer(delegate: self)
                
            }else{
                //Start a new timer with values
                timer = Timer(times:(hours, minutes, seconds), delegate: self)
            }
            //stop fader
            fadeTimer.invalidate()
        }
        
        
        //Fade in and out label
        fadeSideLabel(labelUp)
        fadeSideLabel(labelUpStart)
    }
    
    //Stop timer
    @IBAction func screenSwipedDown(sender: UISwipeGestureRecognizer) {
        //If timer is currently "ended"
        if((player?.playing) != nil){
            self.resetAfterDone()
        }else if(timer != nil){ //If the timer isn't already stopped
            timer?.stopTimer()
            timer = nil
            
            //Start slot fade again
            fadeTimer = getFadeTimer()
        }
        //Fade in and out label
        fadeSideLabel(labelDown)
        fadeSideLabel(labelDownStop)
    }
    
    
//MARK: - Animation methods
    
    func fadeSlot(){
        //Fade out current slot and fade all back in (in case one was switch mid-animation)
        //UIViewAnimationOptions.CurveEaseInOut
        UIView.animateWithDuration(ViewController.FADETIMEDURATION, delay: 0, options: nil, animations: {
                self.currentSlot().alpha = 0
            
            }, completion:{ finished in
                //UIViewAnimationOptions.CurveEaseInOut
                UIView.animateWithDuration(ViewController.FADETIMEDURATION, delay: 0, options: nil, animations: {
                        self.hoursLabel.alpha = 1
                        self.minutesLabel.alpha = 1
                        self.secondsLabel.alpha = 1
                    
                    }, completion:{ finished in
                        
                    }
                )
            }
        )
    }
    
    //Fade in and out side label when triggered by its respective action
    func fadeSideLabel(label : UIView ){
        //Fade in and out label
        UIView.animateWithDuration(ViewController.SIDEFADETIMEDURATIONIN, delay: 0, options: nil, animations: {
            label.alpha = 1
            label.alpha = 1
            }, completion:{ finished in
                //UIViewAnimationOptions.CurveEaseInOut
                UIView.animateWithDuration(ViewController.SIDEFADETIMEDURATIONOUT, delay: 0, options: nil, animations: {
                    label.alpha = 0
                    label.alpha = 0
                    
                    }, completion:{ finished in
                        
                    }
                )
            }
        )
        
    }
    
    
    func resizeIn(label : UIView ){
        //Make the hours, min, and sec, labels resize into the frame from nothing to normal scale
        UIView.animateWithDuration(ViewController.RESIZETIMEDURATION, delay: 0, options: nil, animations: {
            label.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }, completion:nil)
        
    }
    
    

    
    
    

//MARK: - Timer Delegate Methods

    func timerEnded(){
        hoursLabel.text = "**"
        minutesLabel.text = "**"
        secondsLabel.text = "**"
        
        let soundFilePath = NSBundle.mainBundle().pathForResource("Timer", ofType:"m4a")!
        let soundFileURL = NSURL.fileURLWithPath(soundFilePath)!
        
        var error : NSError?
        player = AVAudioPlayer(contentsOfURL: soundFileURL, error: &error)
        if (error != nil)
        {
            print("Error in audioPlayer: \(error!.localizedDescription)")
        }
        player?.numberOfLoops = -1; //Infinite
        player?.prepareToPlay()
        player?.play()
    }
    
    //To reset the timer after it's done
    func resetAfterDone(){
        player?.stop()
        player = nil
        
        hoursLabel.text = "00"
        minutesLabel.text = "00"
        secondsLabel.text = "00"
        
        //Start slot fade again
        fadeTimer = getFadeTimer()
        
        timer = nil
    }
    
    func updateTime(hours : Int, minutes : Int, seconds : Int){
        hoursLabel.text = ifOneDigitAddZero(String(hours))
        minutesLabel.text = ifOneDigitAddZero(String(minutes))
        secondsLabel.text = ifOneDigitAddZero(String(seconds))
    }
    
    
//MARK: - Utility Functions
    
    //If any slot is over 60 flop to next slot (and don't let hours into three digits)
    func overageCheck(){
        //get times
        var seconds = secondsLabel.text!.toInt()!
        var minutes = minutesLabel.text!.toInt()!
        var hours = hoursLabel.text!.toInt()!
        
        if(seconds >= 60){ //If sec is > 60 flop over to min
            minutes = minutes + 1
            if(!(minutes >= 59 && hours >= 99) ){//Don't loop to zero if at maximum
                seconds = 0
            }else{
                seconds = 59
            }
        }
        
        if(minutes >= 60){ //If min is > 60 flop over to hours
            hours = hours + 1
            if(!(hours >= 99)){//Don't loop to zero if at maximum
                minutes = 0
            }else{
                minutes = 59
            }
        }
        
        if(hours > 99){//Don't let hours over 99
            hours = 99
        }
        
        //Set labels
        secondsLabel.text = ifOneDigitAddZero(String(seconds))
        minutesLabel.text = ifOneDigitAddZero(String(minutes))
        hoursLabel.text = ifOneDigitAddZero(String(hours))
    }
    
    func ifOneDigitAddZero(string : String) -> String {
        if count(string) == 1 {
            return "0" + string
        }else{
            return string
        }
    }
    
    //StartFadeTimer
    func getFadeTimer()->NSTimer{
        return NSTimer.scheduledTimerWithTimeInterval((2 * ViewController.FADETIMEDURATION), target: self, selector: Selector("fadeSlot"), userInfo: nil, repeats: true)
    }

    func currentSlot() -> UILabel {
        switch slot{
        case .hours:
            return hoursLabel
        case .minutes:
            return minutesLabel
        case .seconds:
            return secondsLabel
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

