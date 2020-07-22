//
//  FractalClockView.swift
//  FractalClock
//
//  Created by Max Guppy on 12/7/20.
//  Copyright © 2020 TheOnlyMrCat. All rights reserved.
//

import ScreenSaver

class FractalClockView: ScreenSaverView {

    // MARK: - Properties
    
    var configSheetController: ConfigureSheetController = ConfigureSheetController()
    
    private var maximumDepth: Int
    private var fractalType: Int
    private var showSeconds: Bool
    
    private var colourScheme: [NSColor]
    private var fractalPaths: [NSBezierPath]
    
    private var secondHandAngle: Double = 0
    private var minuteHandAngle: Double = 0
    private var hourHandAngle: Double = 0
    private var colourTime: Double = 0
    
    private var clockFrame: NSRect
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        maximumDepth = configSheetController.defaults.integer(forKey: DefaultsKey.fractalDepth.rawValue)
        if maximumDepth == 0 {
            maximumDepth = 8
        }
        fractalType = configSheetController.defaults.integer(forKey: DefaultsKey.fractalType.rawValue)
        showSeconds = configSheetController.defaults.bool(forKey: DefaultsKey.secondHand.rawValue)
        
        colourScheme = Array(repeating: NSColor(calibratedWhite: 1.0, alpha: 1.0), count: maximumDepth + 1)
        fractalPaths = Array(repeating: NSBezierPath(), count: maximumDepth + 1)
        clockFrame = NSRect(x: frame.midX - frame.maxX / 8, y: frame.midY - frame.maxY / 8, width: frame.maxX / 4, height: frame.maxY / 4)
        
        super.init(frame: frame, isPreview: isPreview)
        
        updateAngles()
        updateColours()
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func draw(_ rect: NSRect) {
        NSColor.init(calibratedWhite: 0.1, alpha: 1.0).setFill()
        bounds.fill()
        
        let ticks_color = NSColor(calibratedWhite: 0.7, alpha: 1.0)
        
        drawHands(secondsLength: 0.4, secondsThickness: 0.008, minutesLength: 0.4, minutesThickness: 0.019, hoursLength: 0.175, hoursThickness: 0.0417, centre: NSPoint(x: clockFrame.midX, y: clockFrame.midY), baseColour: ticks_color)
        
        drawTicks(minorColor: ticks_color, minorLength: 0.024720893, minorThickness: 0.004784689, majorColor: ticks_color, majorLength: 0.049441786, majorThickness: 0.009569378, inset: 0.014)
        
        drawNumbers(fontSize: 0.071770334, radius: 0.402711324, colour: ticks_color)
    }

    override func animateOneFrame() {
        super.animateOneFrame()
        
        updateDefaults()
        updateAngles()
        updateColours()
        setNeedsDisplay(bounds)
    }
    
    // MARK: - Helpers
    
    func updateDefaults() {
        maximumDepth = configSheetController.defaults.integer(forKey: DefaultsKey.fractalDepth.rawValue)
        if maximumDepth == 0 {
            maximumDepth = 8
        }
        fractalType = configSheetController.defaults.integer(forKey: DefaultsKey.fractalType.rawValue)
        showSeconds = configSheetController.defaults.bool(forKey: DefaultsKey.secondHand.rawValue)
    }
    
    func updateAngles() {
        let comps = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: Date())
        let nanos = Double(comps.nanosecond ?? 0) / 1_000_000_000.0
        let secs = Double(comps.second ?? 0)
        let mins = Double(comps.minute ?? 0)
        let hrs = Double(comps.hour ?? 0)
        
        if showSeconds {
            colourTime = nanos
            colourTime += secs
            colourTime += mins * 60.0
            colourTime += hrs * 3600.0
        } else {
            colourTime = secs / 1000.0
            colourTime += mins
            colourTime += hrs * 60.0
        }
        
        let secondBase = secs / 60.0
        let secondDeg = secondBase + nanos / 60.0
        secondHandAngle = secondDeg * .pi * 2
        let minuteBase = mins / 60.0
        let minuteDeg = (minuteBase + (secondDeg / 60.0))
        minuteHandAngle = minuteDeg * .pi * 2
        let hourBase = hrs / 12.0
        let hourDeg = (hourBase + ((minuteDeg / 60.0) * (60.0 / 12.0)))
        hourHandAngle = hourDeg * .pi * 2
    }
    
    // Function adapted from https://github.com/HackerPoet/FractalClock
    func updateColours() {
        let r1 = sin(colourTime * 0.017) * 0.5 + 0.5
        let r2 = sin(colourTime * 0.011) * 0.5 + 0.5
        let r3 = sin(colourTime * 0.003) * 0.5 + 0.5
        
        colourScheme.removeAll(keepingCapacity: true)
        for i in 0...maximumDepth {
            let a = Double(maximumDepth - i) / Double(maximumDepth)
            let h = fmod(r2 + 0.5 * a, 1.0)
            let s = 0.5 + 0.5 * r3 - 0.5 * (1.0 - a)
            let v = 0.3 + 0.5 * r1
            if (i == maximumDepth) {
                colourScheme.append(NSColor(calibratedHue: CGFloat(h), saturation: 1.0, brightness: 1.0, alpha: 128.0))
            } else {
                colourScheme.append(NSColor(calibratedHue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(v), alpha: 255.0))
            }
        }
    }
    
    func drawHands(secondsLength: Double, secondsThickness: Double, minutesLength: Double, minutesThickness: Double, hoursLength: Double, hoursThickness: Double, centre: CGPoint, baseColour: NSColor) {
        let secondsEndX = centre.x + CGFloat(sin(secondHandAngle)) * clockFrame.width * CGFloat(secondsLength)
        let secondsEndY = centre.y + CGFloat(cos(secondHandAngle)) * clockFrame.width * CGFloat(secondsLength)
        let secondsEnd = CGPoint(x: secondsEndX, y: secondsEndY)
        
        let minutesEndX = centre.x + CGFloat(sin(minuteHandAngle)) * clockFrame.width * CGFloat(minutesLength)
        let minutesEndY = centre.y + CGFloat(cos(minuteHandAngle)) * clockFrame.width * CGFloat(minutesLength)
        let minutesEnd = CGPoint(x: minutesEndX, y: minutesEndY)
        
        let hoursEndX = centre.x + CGFloat(sin(hourHandAngle)) * clockFrame.width * CGFloat(hoursLength)
        let hoursEndY = centre.y + CGFloat(cos(hourHandAngle)) * clockFrame.width * CGFloat(hoursLength)
        let hoursEnd = CGPoint(x: hoursEndX, y: hoursEndY)
        
        fractalPaths.removeAll(keepingCapacity: true)
        for _ in 0...maximumDepth {
            fractalPaths.append(NSBezierPath())
        }
        
        if fractalType != 2 {
            recursiveDrawHands(secondsLength: secondsLength * 0.7, minutesLength: minutesLength * 0.7, hoursLength: hoursLength * 0.7,
                    centre: secondsEnd,
                    baseAngle: secondHandAngle
            )
        }
        recursiveDrawHands(secondsLength: secondsLength * 0.7, minutesLength: minutesLength * 0.7, hoursLength: hoursLength * 0.7,
                centre: minutesEnd,
                baseAngle: minuteHandAngle
        )
        if fractalType != 1 {
            recursiveDrawHands(secondsLength: secondsLength * 0.7, minutesLength: minutesLength * 0.7, hoursLength: hoursLength * 0.7,
                    centre: hoursEnd,
                    baseAngle: hourHandAngle
            )
        }
        
        for d in 0...maximumDepth {
            let i = maximumDepth - d
            colourScheme[i].setStroke()
            fractalPaths[i].stroke()
        }
        
        baseColour.setStroke()
        
        if showSeconds {
            let secondsPath = NSBezierPath()
            secondsPath.lineWidth = CGFloat(secondsThickness) * clockFrame.width
            secondsPath.lineCapStyle = .round
            secondsPath.move(to: centre)
            secondsPath.line(to: secondsEnd)
            secondsPath.stroke()
        }
        
        let minutesPath = NSBezierPath()
        minutesPath.lineWidth = CGFloat(minutesThickness) * clockFrame.width
        minutesPath.lineCapStyle = .round
        minutesPath.move(to: centre)
        minutesPath.line(to: minutesEnd)
        minutesPath.stroke()
        
        let hoursPath = NSBezierPath()
        hoursPath.lineWidth = CGFloat(hoursThickness) * clockFrame.width
        hoursPath.lineCapStyle = .round
        hoursPath.move(to: centre)
        hoursPath.line(to: hoursEnd)
        hoursPath.stroke()
    }
    
    func recursiveDrawHands(secondsLength: Double, minutesLength: Double, hoursLength: Double, centre: CGPoint, depth: Int = 0, baseAngle: Double) {
        let secondsEndX = centre.x + CGFloat(sin(secondHandAngle + baseAngle)) * clockFrame.width * CGFloat(secondsLength)
        let secondsEndY = centre.y + CGFloat(cos(secondHandAngle + baseAngle)) * clockFrame.width * CGFloat(secondsLength)
        let secondsEnd = CGPoint(x: secondsEndX, y: secondsEndY)
        
        let minutesEndX = centre.x + CGFloat(sin(minuteHandAngle + baseAngle)) * clockFrame.width * CGFloat(minutesLength)
        let minutesEndY = centre.y + CGFloat(cos(minuteHandAngle + baseAngle)) * clockFrame.width * CGFloat(minutesLength)
        let minutesEnd = CGPoint(x: minutesEndX, y: minutesEndY)
        
        let hoursEndX = centre.x + CGFloat(sin(hourHandAngle + baseAngle)) * clockFrame.width * CGFloat(hoursLength)
        let hoursEndY = centre.y + CGFloat(cos(hourHandAngle + baseAngle)) * clockFrame.width * CGFloat(hoursLength)
        let hoursEnd = CGPoint(x: hoursEndX, y: hoursEndY)

        if depth < maximumDepth {
            if fractalType != 2 {
                recursiveDrawHands(secondsLength: secondsLength * 0.7, minutesLength: minutesLength * 0.7, hoursLength: hoursLength * 0.7,
                        centre: secondsEnd,
                    depth: depth + 1,
                        baseAngle: secondHandAngle + baseAngle
                )
            }
            recursiveDrawHands(secondsLength: secondsLength * 0.7, minutesLength: minutesLength * 0.7, hoursLength: hoursLength * 0.7,
                    centre: minutesEnd,
                depth: depth + 1,
                    baseAngle: minuteHandAngle + baseAngle
            )
            if fractalType != 1 {
                recursiveDrawHands(secondsLength: secondsLength * 0.7, minutesLength: minutesLength * 0.7, hoursLength: hoursLength * 0.7,
                        centre: hoursEnd,
                    depth: depth + 1,
                        baseAngle: hourHandAngle + baseAngle
                )
            }
        }
        
        let path = fractalPaths[depth]
        
        if fractalType != 2 {
            path.move(to: centre)
            path.line(to: secondsEnd)
        }
        
        path.move(to: centre)
        path.line(to: minutesEnd)
        
        if fractalType != 1 {
            path.move(to: centre)
            path.line(to: hoursEnd)
        }
    }
    
    // MARK: - Stolen Drawing Helpers
    // Functions taken from https://github.com/soffes/Clock.saver
    
    func drawTicks(minorColor: NSColor, minorLength: Double, minorThickness: Double, majorColor: NSColor? = nil, majorLength: Double? = nil, majorThickness: Double? = nil, inset: Double = 0) {
        // Major
        let majorValues = Array(stride(from: 0, to: 60, by: 5))
        drawTicks(values: majorValues, color: majorColor ?? minorColor, length: majorLength ?? minorLength,
                  thickness: majorThickness ?? minorThickness, inset: inset)

        // Minor
        let minorValues = Array(1...59).filter { !majorValues.contains($0) }
        drawTicks(values: minorValues, color: minorColor, length: minorLength, thickness: minorThickness,
                  inset: inset)
    }

    func drawTicks(values: [Int], color: NSColor, length: Double, thickness: Double, inset: Double, in rect: CGRect? = nil) {
        let rect = rect ?? clockFrame
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let clockWidth = clockFrame.width

        let tickRadius = (rect.width / 2) - (clockWidth * CGFloat(inset))
        for i in values {
            let tickLength = clockWidth * CGFloat(length)
            let progress = Double(i) / 60
            let angle = CGFloat(-(progress * .pi * 2) + .pi / 2)

            color.setStroke()

            let tickPath = NSBezierPath()
            tickPath.move(to: CGPoint(
                x: center.x + cos(angle) * (tickRadius - tickLength),
                y: center.y + sin(angle) * (tickRadius - tickLength)
            ))

            tickPath.line(to: CGPoint(
                x: center.x + cos(angle) * tickRadius,
                y: center.y + sin(angle) * tickRadius
            ))

            tickPath.lineWidth = ceil(clockWidth) * CGFloat(thickness)
            tickPath.stroke()
        }
    }
    
    func drawNumbers(fontSize: CGFloat, radius: Double, values: [Int] = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], in rect: CGRect? = nil, colour: NSColor) {
        let rect = rect ?? clockFrame
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let clockWidth = clockFrame.size.width
        let textRadius = clockWidth * CGFloat(radius)
        let font = NSFont(name: "HelveticaNeue-Light", size: clockWidth * fontSize)!

        let count = CGFloat(values.count)
        for (i, text) in values.enumerated() {
            let string = NSAttributedString(string: String(text), attributes: [
                .foregroundColor: colour,
                .font: font
            ])

            let stringSize = string.size()
            let angle = -(CGFloat(i) / count * .pi * 2) + .pi / 2
            let rect = CGRect(
                x: (center.x + cos(angle) * (textRadius - (stringSize.width / 2))) - (stringSize.width / 2),
                y: center.y + sin(angle) * (textRadius - (stringSize.height / 2)) - (stringSize.height / 2),
                width: stringSize.width,
                height: stringSize.height
            )

            string.draw(in: rect)
        }
    }
    
    // MARK: - ConfigPanel
    
    override var hasConfigureSheet: Bool {
        return true
    }
    
    override var configureSheet: NSWindow? {
        if configSheetController.window == nil {
            Bundle.main.loadNibNamed("Preferences", owner: self, topLevelObjects: nil)
        }
        return configSheetController.window
    }
}
