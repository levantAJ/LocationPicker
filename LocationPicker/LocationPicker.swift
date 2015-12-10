//
//  LocationPicker.swift
//  LocationPicker
//
//  Created by Le Tai on 12/10/15.
//  Copyright © 2015 levantAJ. All rights reserved.
//

import UIKit
import Utils

public final class LocationPicker {
    
    public var navigationControllrer: UINavigationController!
    public var viewController: LocationPickerViewController!
    
    class func frameworkBundle() -> NSBundle? {
        return NSBundle(forClass: LocationPicker.self)
    }
    
    public init() {
        navigationControllrer = Utils.viewController(Constants.LocationPicker.NavigationControllerIdentifier, storyboardName: "LocationPicker", bundle: LocationPicker.frameworkBundle()) as! UINavigationController
        viewController = navigationControllrer.topViewController as! LocationPickerViewController
    }
}

extension Constants {
    struct LocationPicker {
        static let NavigationControllerIdentifier = "LocationPickerNavigationController"
    }
}
