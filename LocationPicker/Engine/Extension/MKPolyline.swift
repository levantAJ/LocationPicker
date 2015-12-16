//
//  MKPolyline.swift
//  LocationPicker
//
//  Created by Le Tai on 12/16/15.
//  Copyright © 2015 levantAJ. All rights reserved.
//

import MapKit
import Polyline

public extension MKPolyline {
    public class func fromPolyline(polyline: Polyline) -> MKPolyline? {
        guard let coordinates = polyline.coordinates else { return nil }
        let coordsPointer: UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer(coordinates)
        return MKPolyline(coordinates: coordsPointer, count: coordinates.count)
    }
}
