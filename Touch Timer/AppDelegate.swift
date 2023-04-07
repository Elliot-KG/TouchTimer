//
//  AppDelegate.swift
//  Touch Timer
//
//  Created by Elliot Goldman on 6/16/15.
//  Copyright (c) 2015 com.ElliotKGoldman. All rights reserved.
//

import UIKit

@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var notification : UILocalNotification!
    static private let SAVEKEY = "saveState"
    static private let STATUSKEY = "isStopwatch"
    static private let FIRSTKEY = "firstRun"

//MARK: - Application behavior methods
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Check if it's the first time running the app and if it is run the tutorial
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if (userDefaults.objectForKey(AppDelegate.FIRSTKEY) == nil){//First time running the app
            let viewController = self.window?.rootViewController as! ViewController
            viewController.runTutorial()
        }else{
            loadAppState()
        }
        return true
    }
    
    func finishedTutorial(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("Enjoy!", forKey: AppDelegate.FIRSTKEY)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        setNotification()
        saveAppState()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        setNotification()
        saveAppState()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        resetNotification()
        loadAppState()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        resetNotification()
        loadAppState()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        setNotification()
        saveAppState()
    }
    
//MARK: - Notification methods
    
    func setNotification(){
        let viewController = self.window?.rootViewController as! ViewController
        if let timer = viewController.timer {
            if (notification == nil && !timer.isStopWatch){
                notification = UILocalNotification()
                notification.fireDate = timer.time
                notification.timeZone = NSTimeZone.localTimeZone()
                notification.alertTitle = "Time's Up!"
                notification.alertBody = "Your timer has finished!"
                notification.alertAction = "Got it!"
                notification.soundName = "TimerRepeat.m4a"
            
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
    }
    
    func application(application: UIApplication,
        didReceiveLocalNotification notification: UILocalNotification){
        let viewController = self.window?.rootViewController as! ViewController
        if let timer = viewController.timer {
            timer.endTimer()
        }
    }
    
    func resetNotification(){
        notification = nil
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
//MARK: - Save-state methods
    
    func saveAppState(){
        let viewController = self.window?.rootViewController as! ViewController
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let timer = viewController.timer { // If a timer exists, save the state of the timer
            //If a timer already exists, delete it
            if(UIApplication.sharedApplication().scheduledLocalNotifications.count > 1){
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }
            userDefaults.setObject(timer.time, forKey: AppDelegate.SAVEKEY)
            userDefaults.setObject(timer.isStopWatch, forKey: AppDelegate.STATUSKEY)
        }else{//Save nil to the key
            userDefaults.setObject(nil, forKey: AppDelegate.SAVEKEY)
        }
    } 
    
    func loadAppState(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        //Load save state from user defaults, if not don't do anything
        if (userDefaults.objectForKey(AppDelegate.SAVEKEY) != nil){
            let date = userDefaults.objectForKey(AppDelegate.SAVEKEY) as! NSDate
            let isStopWatch = userDefaults.objectForKey(AppDelegate.STATUSKEY) as! Bool
            let viewController = self.window?.rootViewController as! ViewController
            viewController.initWithSaveState(date, isStopwatch: isStopWatch)
        }
        
        //Reset save state
        userDefaults.setObject(nil, forKey: AppDelegate.SAVEKEY)
    }
    
    


}

