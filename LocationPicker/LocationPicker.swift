//
//  LocationPicker.swift
//  LocationPicker
//
//  Created by Le Tai on 12/10/15.
//  Copyright © 2015 levantAJ. All rights reserved.
//

import UIKit
import Utils

public let SharedDataSource: LocationPickerDataSource = LocationPicker.sharedInstance.dataSource

public final class LocationPicker {
    
    public static let sharedInstance = LocationPicker()
    public var navigationController: UINavigationController!
    public var viewController: LocationPickerViewController!
    public var dataSource: LocationPickerDataSource!
    
    class func frameworkBundle() -> NSBundle? {
        return NSBundle(forClass: LocationPicker.self)
    }
    
    public class func standardLocationPicker(dataSource: LocationPickerDataSource) -> LocationPicker {
        sharedInstance.dataSource = dataSource
        sharedInstance.navigationController = Utils.viewController(Constants.LocationPicker.NavigationControllerIdentifier, storyboardName: "LocationPicker", bundle: LocationPicker.frameworkBundle()) as! UINavigationController
        sharedInstance.navigationController.navigationBar.barTintColor = dataSource.primayColor()
        sharedInstance.navigationController.navigationBar.tintColor = dataSource.navigationTextColor()
        sharedInstance.viewController = sharedInstance.navigationController.topViewController as! LocationPickerViewController
        return sharedInstance
    }
}

extension Constants {
    struct LocationPicker {
        static let NavigationControllerIdentifier = "LocationPickerNavigationController"
    }
}
