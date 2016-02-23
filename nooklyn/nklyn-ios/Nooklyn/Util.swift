//
//  Util.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/3/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

let SITE_DOMAIN = "https://nooklyn.com"
//let SITE_DOMAIN = "https://nooklyn-dev.herokuapp.com"
//let SITE_DOMAIN = "https://nooklyn-dev-pr-#.herokuapp.com"
//let SITE_DOMAIN = "http://localhost:3000"

let NOOKLYN_OFFICE_PHONE_NUMBER = "3473183595"

// MARK: - Keyboard direction

enum KeyboardDirection {
    case Up
    case Down
}

// MARK: - Subway line color priority map

var subwayLineColorPriorityMap: [String: Int] {
    return [
        "1": 1,
        "2": 1,
        "3": 1,
        "4": 2,
        "5": 2,
        "6": 2,
        "7": 3,
        "A": 4,
        "C": 4,
        "E": 4,
        "B": 5,
        "D": 5,
        "F": 5,
        "M": 5,
        "G": 6,
        "J": 7,
        "Z": 7,
        "L": 8,
        "N": 9,
        "Q": 9,
        "R": 9,
        "S": 10
    ]
}

class Util {

    // MARK: - Sorted subway lines

    class func sortedSubwayLines(subwayLines: [String]) -> [String] {
        // sort subway lines by color priority, line
        return subwayLines.sort {
            let lineA = $0
            let colorPriorityA = subwayLineColorPriorityMap[lineA]
            
            let lineB = $1
            let colorPriorityB = subwayLineColorPriorityMap[lineB]
            
            return colorPriorityA == colorPriorityB ? (lineA < lineB) : (colorPriorityA < colorPriorityB)
        }
    }

    // MARK: - Formatted subway line url

    class func formattedSubwayLineURL(subwayLine: String) -> String {
        return SUBWAY_LINE_URL.stringByReplacingOccurrencesOfString("<SUBWAY_LINE>", withString:subwayLine)
    }
}

// MARK: - Check device

func IS_IPAD() -> Bool {
    return UIDevice.currentDevice().userInterfaceIdiom == .Pad
}

func IS_IPHONE6PLUS() -> Bool {
    return UIDevice().userInterfaceIdiom == .Phone
        && UIScreen.mainScreen().nativeBounds.height == 2208
}

func IS_IPHONE6() -> Bool {
    return UIDevice().userInterfaceIdiom == .Phone
        && UIScreen.mainScreen().nativeBounds.height == 1334
}

func IS_IPHONE5() -> Bool {
    return UIDevice().userInterfaceIdiom == .Phone
        && UIScreen.mainScreen().nativeBounds.height == 1136
}

func IS_IPHONE4() -> Bool {
    return UIDevice().userInterfaceIdiom == .Phone
        && UIScreen.mainScreen().nativeBounds.height == 960
}

// MARK: - Get screen width

func getScreenWidth() -> CGFloat {
    let screenSize = UIScreen.mainScreen().bounds
    return screenSize.width
}

// MARK: - Stopwatch

class StopWatch {
    var startTime: CFTimeInterval!
    var endTime: CFTimeInterval!
    
    func start() {
        self.startTime = CACurrentMediaTime()
    }
    
    func stop() {
        self.endTime = CACurrentMediaTime()
    }
    
    func report(label label: String) {
        print("\(label): \(self.endTime - self.startTime)")
    }
}

// MARK: - Delay

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue(),
        closure
    )
}

// MARK: - Array

extension Array where Element : Equatable {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

// MARK: - String

extension String {
    func strip() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func beginsWith(str: String) -> Bool {
        if let range = self.rangeOfString(str) {
            return range.startIndex == self.startIndex
        }
        return false
    }
    
    func endsWith(str: String) -> Bool {
        if let range = self.rangeOfString(str, options:NSStringCompareOptions.BackwardsSearch) {
            return range.endIndex == self.endIndex
        }
        return false
    }
    
    func contains(str: String) -> Bool {
        return self.rangeOfString(str) != nil
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        let boundingBox = self.boundingRectWithSize(
            constraintRect,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil
        )
        return boundingBox.height
    }
}

// MARK: - UIColor

extension UIColor {
    convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
    convenience init?(hexString: String, alpha: Float) {
        var hex = hexString
        
        // if string has hex, remove it
        if hex.hasPrefix("#") {
            hex = hex.substringFromIndex(hex.startIndex.advancedBy(1))
        }
        
        if hex.rangeOfString("(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .RegularExpressionSearch) != nil {
            // deal with 3 character hex strings
            if hex.characters.count == 3 {
                let redHex   = hex.substringToIndex(hex.startIndex.advancedBy(1))
                let greenHex = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(1), end: hex.startIndex.advancedBy(2)))
                let blueHex  = hex.substringFromIndex(hex.startIndex.advancedBy(2))
                
                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
            }
            
            let redHex = hex.substringToIndex(hex.startIndex.advancedBy(2))
            let greenHex = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(2), end: hex.startIndex.advancedBy(4)))
            let blueHex = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(4), end: hex.startIndex.advancedBy(6)))
            
            var redInt:   CUnsignedInt = 0
            var greenInt: CUnsignedInt = 0
            var blueInt:  CUnsignedInt = 0
            
            NSScanner(string: redHex).scanHexInt(&redInt)
            NSScanner(string: greenHex).scanHexInt(&greenInt)
            NSScanner(string: blueHex).scanHexInt(&blueInt)
            
            self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: CGFloat(alpha))
        }
        else {
            self.init()
            return nil
        }
    }
}

// MARK: - Image file size in MB

func getImageFileSizeInMB(image: UIImage) -> Float {
    var imageFileSizeinMB = Float(0)
    imageFileSizeinMB = Float(UIImageJPEGRepresentation(image, 1)!.length) / 1000000
    return imageFileSizeinMB
}
