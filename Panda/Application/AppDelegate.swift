//
//  AppDelegate.swift
//  devMod
//
//  Created by Paolo Tagliani on 10/23/14.
//  Copyright (c) 2014 Paolo Tagliani. All rights reserved.
//

import Cocoa
import AppKit
import Fabric
import Crashlytics

enum currentInterface{
    case light
    case dark
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    @IBOutlet weak var appMenu: NSMenu!
    @IBOutlet weak var hourSwitchButton: NSMenuItem!

    var statusItem:NSStatusItem?
    var statusButton:NSStatusBarButton?
    var preferenceWindow:NSPreferencePanelWindowController?
    var aboutWindow:About?
    var darkTime:NSDate?
    var lightTime:NSDate?
    var dateCheckTimer:Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Fabric.with([Crashlytics.self])
        hourSwitchButton.state = NSControl.StateValue.on
        
        dateCheckTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(AppDelegate.checkTime), userInfo: nil, repeats: true)
        
        //Update icon with current interface state
        updateIconForCurrentMode()
        DistributedNotificationCenter.default().addObserver(self, selector:#selector(AppDelegate.updateIconForCurrentMode), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
    }
    
    override func awakeFromNib() {
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: -1)
        
        statusButton = statusItem!.button!
        statusButton?.target = self;
        statusButton?.action = #selector(AppDelegate.barButtonMenuPressed(sender:))
        statusButton?.sendAction(on: NSEvent.EventTypeMask(rawValue: NSEvent.EventTypeMask.RawValue(Int((NSEvent.EventTypeMask.leftMouseUp.union(NSEvent.EventTypeMask.rightMouseUp)).rawValue))))
        
        appMenu.delegate = self
    }

    func currentInterfaceState () -> currentInterface{
        let scriptSource = """
                            tell application "System Events"
                            tell appearance preferences
                            get dark mode
                            end tell
                            end tell
                            """
        var scriptError: NSDictionary?
        if let scriptObj = NSAppleScript(source: scriptSource) {
            let output = scriptObj.executeAndReturnError(&scriptError)
            if(output.booleanValue) {
                return currentInterface.dark;
            } else {
                return currentInterface.light;
            }
        }
        if let error = scriptError {
            NSLog("Error in AppleScript execution: %@", error)
        }
        return currentInterface.light;
    }
    
    func activateDevMode(sender: AnyObject) {
        let currentInterfaceLight:currentInterface = currentInterfaceState()
        
        switch currentInterfaceLight{
        case .light:
            activateDarkInterface()
        case .dark:
            activateLightInterface()
        }
    }
  
    @objc func updateIconForCurrentMode() {
        let currentInterfaceLight:currentInterface = currentInterfaceState()
        
        switch currentInterfaceLight{
        case .light:
            statusButton?.image = NSImage(named: NSImage.Name(rawValue: "panda-white"))
        case .dark:
            statusButton?.image = NSImage(named: NSImage.Name(rawValue: "panda-dark"))
        }
    }
    
    func activateLightInterface(){
        print("Switch to Light")
        let scriptSource = """
                            tell application "System Events"
                            tell appearance preferences
                            set dark mode to false
                            end tell
                            end tell
                            """
        var scriptError: NSDictionary?
        if let scriptObj = NSAppleScript(source: scriptSource) {
            scriptObj.executeAndReturnError(&scriptError)
        }
        if let error = scriptError {
            NSLog("Error in AppleScript execution: %@", error)
        }

    }
    
    func activateDarkInterface(){
        print("Switch to Darks")
        let scriptSource = """
                            tell application "System Events"
                            tell appearance preferences
                            set dark mode to true
                            end tell
                            end tell
                            """
        var scriptError: NSDictionary?
        if let scriptObj = NSAppleScript(source: scriptSource) {
            scriptObj.executeAndReturnError(&scriptError)
        }
        if let error = scriptError {
            NSLog("Error in AppleScript execution: %@", error)
        }
    }
    
    @objc func barButtonMenuPressed(sender: NSStatusBarButton!){
        let event:NSEvent! = NSApp.currentEvent!
        print (event.description)
        if (event.type == NSEvent.EventType.rightMouseUp) {
            statusItem?.menu = appMenu
            statusItem?.popUpMenu(appMenu) //Force the menu to be shown, otherwise it'll not
        }
        else{
            activateDevMode(sender: sender)
            hourSwitchButton.state = NSControl.StateValue.off;
        }
    }
    
  //MARK: - NSMenuDelegate
    func menuDidClose(_ menu: NSMenu) {
        statusItem?.menu = nil
    }
    
  //MARK: -Action management
    @IBAction func preferencesPressed(sender: AnyObject) {
        preferenceWindow = NSPreferencePanelWindowController(windowNibName: NSNib.Name(rawValue: "NSPreferencePanelWindowController"))
        let window:NSWindow! = preferenceWindow?.window!
        window.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func aboutPressed(sender: AnyObject) {
        aboutWindow = About(windowNibName: NSNib.Name(rawValue: "About"))
        let window:NSWindow! = aboutWindow?.window!
        window.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func hourSwitchPressed(sender: AnyObject) {
        let newState = hourSwitchButton.state == NSControl.StateValue.on ? NSControl.StateValue.off : NSControl.StateValue.on
        hourSwitchButton.state = newState
    }
    
    //MARK: - Check timer
    @objc func checkTime(){
        let now = NSDate()
        
        //Tira su le date dai default di sistema
        darkTime =  UserDefaults.standard.value(forKey: "DarkTime") as? NSDate
        lightTime =  UserDefaults.standard.value(forKey: "LightTime") as? NSDate
        
        let interfaceStateForTime = interfaceStateForCurrentTime(darkDate: translateDateToday(date: darkTime), lightDate: translateDateToday(date: lightTime), now: now)
        let currentInterface = currentInterfaceState()
        
        if (interfaceStateForTime != currentInterface) && (hourSwitchButton.state == NSControl.StateValue.on){
            switch interfaceStateForTime{
            case .light:
                activateLightInterface()
            case .dark:
                activateDarkInterface()
            }
        }
    }
    
    func translateDateToday(date:NSDate?) -> (NSDate?){
        if let date = date{
            let calendar = Calendar.current
            let calendarflag: Set<Calendar.Component> = [Calendar.Component.day, Calendar.Component.month, Calendar.Component.year]
            let hourFlag: Set<Calendar.Component> = [Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second]
            let now = Date()
            
            let componentsCalendar = calendar.dateComponents(calendarflag, from: now)
            let componentsHour = calendar.dateComponents(hourFlag, from: date as Date)
            
            var finalComponents = DateComponents()
            finalComponents = componentsCalendar
            finalComponents.hour = componentsHour.hour
            finalComponents.minute = componentsHour.minute
            finalComponents.second = componentsHour.second
            
            return calendar.date(from: finalComponents) as NSDate?
        }
        else{
            return nil
        }
    }
    
    func interfaceStateForCurrentTime(darkDate:NSDate?, lightDate:NSDate?, now:NSDate)->(currentInterface){
        if lightDate == nil && darkDate == nil{
            return currentInterfaceState()
        }
        else if darkTime == nil{
            return lightDate!.compare(now as Date as Date) == ComparisonResult.orderedAscending ? currentInterface.light : currentInterface.dark
        }
        else if lightDate == nil{
            _ = darkDate!.compare(now as Date)
            return darkDate!.compare(now as Date) == ComparisonResult.orderedAscending ? currentInterface.dark : currentInterface.light
        }
        else{
            let comparison = lightDate!.compare(darkDate! as Date)
            if comparison == ComparisonResult.orderedDescending{ //Dark<Light
                let darkComparison = darkDate!.compare(now as Date)
                let lightComparison = lightDate!.compare(now as Date)
                
                //Now > Light || Now < Dark     ->light
                if darkComparison == ComparisonResult.orderedDescending || lightComparison == ComparisonResult.orderedAscending{
                    return currentInterface.light
                }
                //Now < Light && Now > Dark     ->dark
                if darkComparison == ComparisonResult.orderedAscending && lightComparison == ComparisonResult.orderedDescending{
                    return currentInterface.dark
                }
            }
            else{ //Dark>Light
                let darkComparison = darkDate!.compare(now as Date)
                let lightComparison = lightDate!.compare(now as Date)
                //Now > Dark || Now < Light     ->dark
                if darkComparison == ComparisonResult.orderedAscending || lightComparison == ComparisonResult.orderedDescending{
                    return currentInterface.dark
                }
                //Now < Dark && Now > Light     ->light
                if darkComparison == ComparisonResult.orderedDescending && lightComparison == ComparisonResult.orderedAscending{
                    return currentInterface.light
                }
            }
        }
        return currentInterfaceState()
    }
}

