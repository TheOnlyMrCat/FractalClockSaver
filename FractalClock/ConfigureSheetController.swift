//
//  ConfigureSheetManager.swift
//  FractalClock
//
//  Created by Max Guppy on 13/7/20.
//  Copyright © 2020 TheOnlyMrCat. All rights reserved.
//

import AppKit
import Foundation
import ScreenSaver

enum DefaultsKey: String {
    case fractalDepth = "FCFractalDepth"
    case fractalType = "FCFractalType"
    case secondHand = "FCSecondsDisplay"
}

class ConfigureSheetController: NSObject {
    
    var defaults: UserDefaults
    
    // MARK: - Initialization
    
    override init() {
        let bundle = Bundle(for: ConfigureSheetController.self)
        defaults = ScreenSaverDefaults(forModuleWithName: bundle.bundleIdentifier!)!
        super.init()
        
        bundle.loadNibNamed("Preferences", owner: self, topLevelObjects: nil)
        
        let d = defaults.integer(forKey: DefaultsKey.fractalDepth.rawValue)
        if d == 0 {
            depth.integerValue = 8
        } else {
            depth.integerValue = d
        }
        
        type.selectItem(at: defaults.integer(forKey: DefaultsKey.fractalType.rawValue))
        
        if defaults.object(forKey: DefaultsKey.secondHand.rawValue) as? Bool ?? true {
            second.state = .on
        } else {
            second.state = .off
        }
    }
    
    // MARK: - References
    
    @IBOutlet var window: NSWindow?
    @IBOutlet var depth: NSTextField!
    @IBOutlet var type: NSPopUpButton!
    @IBOutlet var second: NSButton!
    
    @IBAction func secondsToggled(_ sender: NSButton) {
        if sender.state == .off {
            type.selectItem(at: 2)
            type.isEnabled = false
        } else {
            type.selectItem(at: defaults.integer(forKey: DefaultsKey.fractalType.rawValue))
            type.isEnabled = true
        }
    }
    
    @IBAction func saveAndClose(_ sender: Any) {
        defaults.set(depth.integerValue, forKey: DefaultsKey.fractalDepth.rawValue)
        defaults.set(type.indexOfSelectedItem, forKey: DefaultsKey.fractalType.rawValue)
        if second.state == .on {
            defaults.set(true, forKey: DefaultsKey.secondHand.rawValue)
        } else {
            defaults.set(false, forKey: DefaultsKey.secondHand.rawValue)
        }
        
        defaults.synchronize()
        
        close(sender)
    }
    
    @IBAction func close(_ sender: Any) {
        guard let window = window else { return }

        if let parent = window.sheetParent {
            parent.endSheet(window)
        } else {
            window.close()
        }
    }
}
