//
//  NSPreferencePanelWindowController.swift
//  devMod
//
//  Created by Paolo Tagliani on 10/25/14.
//  Copyright (c) 2014 Paolo Tagliani. All rights reserved.
//

import Cocoa
import Quartz


class NSPreferencePanelWindowController: NSWindowController {

    @IBOutlet weak var launchAtStartupButton: NSButton!
    @IBOutlet weak var darkModeDatePicker: NSDatePicker!
    @IBOutlet weak var lightModeDatePicker: NSDatePicker!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.window?.titleVisibility = NSWindow.TitleVisibility.hidden;

        //Set login item state
        launchAtStartupButton.state = PALoginItemUtility.isCurrentApplicatonInLoginItems() ? NSControl.StateValue.on : NSControl.StateValue.off
        
        //Set darkDate
        if let darkDate = UserDefaults.standard.object(forKey: "DarkTime") as? NSDate {
            darkModeDatePicker.dateValue = darkDate as Date
        }
        
        //Set light date
        if let lightDate = UserDefaults.standard.object(forKey: "LightTime") as? NSDate{
            lightModeDatePicker.dateValue = lightDate as Date
        }
    }
    
    @IBAction func launchLoginPressed(sender: NSButton) {
        if sender.state == NSControl.StateValue.on{
            PALoginItemUtility.addCurrentApplicatonToLoginItems()
        }
        else{
            PALoginItemUtility.removeCurrentApplicatonToLoginItems()
        }
    }
    
    @IBAction func darkTimeChange(sender: NSDatePicker) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.darkTime = sender.dateValue as NSDate
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(sender.dateValue, forKey: "DarkTime")
        userDefaults.synchronize()
    }
    
    @IBAction func lightTimeChange(sender: NSDatePicker) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.lightTime = sender.dateValue as NSDate
        let userDefaults = UserDefaults.standard
        UserDefaults.standard.setValue(sender.dateValue, forKey: "LightTime")
        userDefaults.synchronize()
    }
    
}
