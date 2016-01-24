//
//  LocationPickerDataSource.swift
//  LocationPicker
//
//  Created by Le Tai on 1/24/16.
//  Copyright © 2016 levantAJ. All rights reserved.
//

import UIKit

public protocol LocationPickerDataSource {
    func currentLocationImage() -> UIImage
    func currentLocationIsCircle() -> Bool
    func currentLocationSize() -> CGSize
    func chooseOnMapImage() -> UIImage
    func recentlyImage() -> UIImage
    func locationImage() -> UIImage
    func navigationTextColor() -> UIColor
    func primayColor() -> UIColor
}