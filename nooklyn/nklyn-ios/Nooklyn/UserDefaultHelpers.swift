//
//  UserDefaultHelpers.swift
//  Nooklyn
//
//  Created by Joe Gallo on 1/26/16.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit

func alreadyLaunchedOnce() -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let alreadyLaunchedOnce = userDefaults.boolForKey("alreadyLaunchedOnce")
    return alreadyLaunchedOnce
}

func setAlreadyLaunchedOnce(alreadyLaunchedOnce: Bool) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(alreadyLaunchedOnce, forKey: "alreadyLaunchedOnce")
}

func didOneTimeClear() -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let didOneTimeClear = userDefaults.boolForKey("didOneTimeClear")
    return didOneTimeClear
}

func setDidOneTimeClear(didOneTimeClear: Bool) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(didOneTimeClear, forKey: "didOneTimeClear")
}

func isFirstFavoriteListingDrop() -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let firstFavoriteListingDrop = userDefaults.boolForKey("firstFavoriteListingDrop")
    return firstFavoriteListingDrop
}

func markFirstFavoriteListingDrop() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(true, forKey: "firstFavoriteListingDrop")
}

func isFirstFavoriteMateDrop() -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let firstFavoriteMateDrop = userDefaults.boolForKey("firstFavoriteMateDrop")
    return firstFavoriteMateDrop
}

func markFirstFavoriteMateDrop() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(true, forKey: "firstFavoriteMateDrop")
}

func isFirstIgnoreListingDrop() -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let firstIgnoreListingDrop = userDefaults.boolForKey("firstIgnoreListingDrop")
    return firstIgnoreListingDrop
}

func markFirstIgnoreListingDrop() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(true, forKey: "firstIgnoreListingDrop")
}

func isFirstIgnoreMateDrop() -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let firstIgnoreMateDrop = userDefaults.boolForKey("firstIgnoreMateDrop")
    return firstIgnoreMateDrop
}

func markFirstIgnoreMateDrop() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(true, forKey: "firstIgnoreMateDrop")
}

func clearUserDefaults() {
    let appDomain = NSBundle.mainBundle().bundleIdentifier
    NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
}

func printUserDefaults() {
    print(NSUserDefaults.standardUserDefaults().dictionaryRepresentation())
}
