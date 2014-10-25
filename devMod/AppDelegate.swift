//
//  AppDelegate.swift
//  devMod
//
//  Created by Paolo Tagliani on 10/23/14.
//  Copyright (c) 2014 Paolo Tagliani. All rights reserved.
//

import Cocoa
import Appkit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var appMenu: NSMenu!
    var statusItem:NSStatusItem?
    var statusButton:NSStatusBarButton?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

    override func awakeFromNib() {
        var statusBar = NSStatusBar.systemStatusBar()
        statusItem = statusBar.statusItemWithLength(-1)
        
        statusButton = statusItem!.button!
        statusButton?.title = "devMod"
        statusButton?.target = self;
        statusButton?.action = "barButtonMenuPressed:"
        statusButton?.sendActionOn(Int((NSEventMask.LeftMouseDownMask | NSEventMask.RightMouseDownMask).rawValue))
    }

    func activateDevMode(sender: AnyObject) {
        var interfaceValue:CFString = "AppleInterfaceStyle" as CFString
        var property:CFPropertyList? = CFPreferencesCopyValue(interfaceValue, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
        if let light: CFPropertyList = property{
            if light as NSString == "Light"{
                activateDarkInterface()
            }
            else{
                activateLightInterface()
            }
        }
        else{
            activateDarkInterface()
        }
        
    }
    
    func activateLightInterface(){
        println("Switch to Light")
        DevModeInterfaceManager.switchToLightMode()
    }
    
    func activateDarkInterface(){
        println("Switch to Darks")
        DevModeInterfaceManager.switchToDarkMode()
    }
    
    func barButtonMenuPressed(sender: NSStatusBarButton!){
        var event:NSEvent! = NSApp.currentEvent!
        if event.type == NSEventType.LeftMouseDown {
            activateDevMode(sender)
        }
        else{
            
        }
    }
}

