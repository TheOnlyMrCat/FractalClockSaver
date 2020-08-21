import AppKit
import Foundation
import ScreenSaver

enum DefaultsKey: String {
    case fractalDepth = "FCFractalDepth"
    case fractalType = "FCFractalType"
    case secondHand = "FCSecondsDisplay"
    case flavourText = "FCFlavorText"
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
            depthStepper.integerValue = 8
        } else {
            depth.integerValue = d
            depthStepper.integerValue = d
        }
        
        flavourText.stringValue = defaults.string(forKey: DefaultsKey.flavourText.rawValue) ?? ""
        
        let t = defaults.integer(forKey: DefaultsKey.fractalType.rawValue)
        type.selectItem(at: t)
        
        setUnstableText(fractalType: t);
        
        if defaults.object(forKey: DefaultsKey.secondHand.rawValue) as? Bool ?? true {
            second.state = .on
        } else {
            second.state = .off
        }
    }
    
    // MARK: - Helpers
    
    func setUnstableText(fractalType: Int) {
        if fractalType == 0 {
            instabilityText.stringValue = "Values above 8 tend to be unstable"
        } else {
            instabilityText.stringValue = "Values above 14 tend to be unstable"
        }
    }
    
    // MARK: - References
    
    @IBOutlet var window: NSWindow?
    @IBOutlet var depth: NSTextField!
    @IBOutlet var depthStepper: NSStepper!
    @IBOutlet var type: NSPopUpButton!
    @IBOutlet var second: NSButton!
    @IBOutlet var instabilityText: NSTextField!
    @IBOutlet var flavourText: NSTextField!
    
    @IBAction func typeChanged(_ sender: NSPopUpButton) {
        setUnstableText(fractalType: sender.indexOfSelectedItem)
    }
    
    @IBAction func secondsToggled(_ sender: NSButton) {
        if sender.state == .off {
            type.selectItem(at: 2)
            setUnstableText(fractalType: type.indexOfSelectedItem)
            type.isEnabled = false
        } else {
            type.selectItem(at: defaults.integer(forKey: DefaultsKey.fractalType.rawValue))
            setUnstableText(fractalType: type.indexOfSelectedItem)
            type.isEnabled = true
        }
    }
    
    @IBAction func saveAndClose(_ sender: Any) {
        defaults.set(depth.integerValue, forKey: DefaultsKey.fractalDepth.rawValue)
        defaults.set(flavourText.stringValue, forKey: DefaultsKey.flavourText.rawValue)
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
