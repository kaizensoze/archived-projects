//
//  Formatters.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/19/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit

// MARK: - Format price

func formatPrice(priceInt: Int?) -> String! {
    guard let price = priceInt else {
        return ""
    }
    return getNumberFormatter().stringFromNumber(price)
}

func getNumberFormatter() -> NSNumberFormatter {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    formatter.maximumFractionDigits = 0
    return formatter
}

// MARK: - Price from string

func priceFromString(string: String) -> Int? {
    var stringCopy = string
    if string.rangeOfString("$") == nil {
        stringCopy = "$" + stringCopy
    }
    let noCommasString = stringCopy.stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    return getNumberFormatter().numberFromString(noCommasString)?.integerValue
}

// MARK: - String from date

func stringFromShortDate(date: NSDate?) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .MediumStyle
    return stringFromDate(date, dateFormatter: dateFormatter)
}

func stringFromDate(date: NSDate?) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return stringFromDate(date, dateFormatter: dateFormatter)
}

func stringFromDate(date: NSDate?, dateFormatter: NSDateFormatter?) -> String {
    guard let inputDate = date, formatter = dateFormatter else {
        return ""
    }
    return formatter.stringFromDate(inputDate)
}

// MARK: - Date from string

func shortDateFromString(dateString: String) -> NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .MediumStyle
    return dateFromString(dateString, dateFormatter: dateFormatter)
}

func dateFromString(dateString: String) -> NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFromString(dateString, dateFormatter: dateFormatter)
}

func dateFromString(dateString: String, dateFormatter: NSDateFormatter?) -> NSDate? {
    if let formatter = dateFormatter {
        return formatter.dateFromString(dateString)
    }
    return nil
}
