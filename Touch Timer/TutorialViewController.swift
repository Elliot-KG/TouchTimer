//
//  TutorialViewController.swift
//  Touch Timer
//
//  Created by Elliot Goldman on 7/4/15.
//  Copyright (c) 2015 com.ElliotKGoldman. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController: UIViewController {
    
    private static let FADETIMEDURATION = 0.6
    private static let RESIZETIMEDURATION = 1.0
    private var step = 0
    
    //MARK: - UI Outlets
    @IBOutlet weak var centerText: UILabel!
    @IBOutlet weak var directionImageUp: UIImageView!
    @IBOutlet weak var directionImageDown: UIImageView!
    @IBOutlet weak var directionImageLeft: UIImageView!
    @IBOutlet weak var directionImageRight: UIImageView!
    @IBOutlet weak var gotItButton: UIButton!
    
    //MARK: - view methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide all the side labels (to be faded in later)
        directionImageUp.alpha = 0
        directionImageDown.alpha = 0
        directionImageLeft.alpha = 0
        directionImageRight.alpha = 0
        
        //Set the main text label and the gotIt button text
        centerText.text = "Welcome to Elbow Timer!"
        gotItButton.setTitle("Touch!", forState: UIControlState.Normal)
        //Set size to nothing in order to resize in
        gotItButton.transform = CGAffineTransformMakeScale(0.0, 0.0)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //Resize the gotItButton into the frame from nothing to normal scale
        UIView.animateWithDuration(TutorialViewController.RESIZETIMEDURATION, delay: 0, options: nil, animations: {
            self.gotItButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }, completion:nil)
    }
    
    @IBAction func gotIt(sender: UIButton) {
        step++
        switch step{
        case 1:
            gotItButton.setTitle("Got it!", forState: .Normal)
            centerText.text = "The slots are set up: \n Hours : Minutes : Seconds"
        
        case 1:
            centerText.text = "Tap the screen to increase the time in the flashing slot"
            
            
        case 2:
            centerText.text = "Long press to change the current slot"
        
        case 3:
            fadeIn(directionImageLeft)
            centerText.text = "Swipe left to reset the current slot"
        
        case 4:
            directionImageLeft.alpha = 0
            fadeIn(directionImageRight)
            centerText.text = "Swipe right to reset all slots"
        
        case 5:
            directionImageRight.alpha = 0
            fadeIn(directionImageUp)
            centerText.text = "Swipe up to start the timer"
        
        case 6:
            directionImageUp.alpha = 0
            fadeIn(directionImageDown)
            centerText.text = "Swipe down to stop the timer"
        
        case 7:
            //Set tutorial as complete
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.finishedTutorial()
            
            //Resize out the elements
            UIView.animateWithDuration(TutorialViewController.RESIZETIMEDURATION, delay: 0, options: nil, animations: {
                self.gotItButton.transform = CGAffineTransformMakeScale(0.0, 0.0)
                }, completion:nil)
            
            UIView.animateWithDuration(TutorialViewController.RESIZETIMEDURATION, delay: 0, options: nil, animations: {
                self.centerText.transform = CGAffineTransformMakeScale(0.0, 0.0)
                }, completion:{finished in
                    //Return to normal app
                    self.dismissViewControllerAnimated(true, completion: nil)
            })
            
        default:
            print("Error! Too many steps!")
        }
    }
    
    //MARK: - animation methods
    func fadeIn(view : UIView){
        UIView.animateWithDuration(TutorialViewController.FADETIMEDURATION, delay: 0, options: nil, animations: {
            view.alpha = 1
            }, completion:{ finished in
            }
        )
    }
    
    
}