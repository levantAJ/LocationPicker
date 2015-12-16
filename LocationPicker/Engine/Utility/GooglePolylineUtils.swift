//
//  GoogleUtils.swift
//  CloudBike
//
//  Created by Le Tai on 9/6/15.
//  Copyright © 2015 Le Van Tai. All rights reserved.
//

import CoreLocation
import Polyline

enum GoogleStatus: String {
    case OK   = "OK"
    case ZERO = "ZERO_RESULTS"
}

public final class GooglePolylineUtils {
    public class func startLocationOfPolyline(googleRoutingResult: [String: AnyObject]) -> CLLocationCoordinate2D? {
        guard let status = googleRoutingResult["status"] as? String,
            routes = googleRoutingResult["routes"] as? [AnyObject]
            where status == GoogleStatus.OK.rawValue && routes.count > 0,
            let route = routes[0] as? [String: AnyObject],
            legs = route["legs"] as? [AnyObject]
            where legs.count > 0,
            let leg = legs[0] as? [String: AnyObject],
            start_location = leg["start_location"] as? [String: Double],
            lat = start_location["lat"],
            lng = start_location["lng"] else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    public class func endLocationOfPolyline(googleRoutingResult: [String: AnyObject]) -> CLLocationCoordinate2D? {
        guard let status = googleRoutingResult["status"] as? String,
            routes = googleRoutingResult["routes"] as? [AnyObject]
            where status == GoogleStatus.OK.rawValue && routes.count > 0,
            let route = routes[0] as? [String: AnyObject],
            legs = route["legs"] as? [AnyObject]
            where legs.count > 0, let leg = legs[legs.count - 1] as? [String: AnyObject],
            start_location = leg["end_location"] as? [String: Double],
            lat = start_location["lat"],
            lng = start_location["lng"] else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    public class func polyline(googleRoutingResult: [String: AnyObject]) -> Polyline? {
        guard let status = googleRoutingResult["status"] as? String,
            routes = googleRoutingResult["routes"] as? [AnyObject]
            where status == GoogleStatus.OK.rawValue && routes.count > 0,
            let route = routes[0] as? [String: AnyObject],
            overview_polyline = route["overview_polyline"] as? [String: String],
            points = overview_polyline["points"] else { return nil }
        return Polyline(encodedPolyline: points)
    }
    
    public class func distance(googleRoutingResult: [String: AnyObject]) -> Double? {
        guard let status = googleRoutingResult["status"] as? String,
            routes = googleRoutingResult["routes"] as? [AnyObject]
            where status == GoogleStatus.OK.rawValue && routes.count > 0,
            let route = routes[0] as? [String: AnyObject],
            legs = route["legs"] as? [AnyObject]
            where legs.count > 0 else { return nil }
        var distanceValue: Double = 0
        for leg in legs {
            guard let leg = leg as? [String: AnyObject],
                distance = leg["distance"] as? [String: AnyObject],
                value = distance["value"] as? Double else { continue }
            distanceValue += value
        }
        return distanceValue
    }
    
    public class func street(address: String) -> (String, String) {
        let regions = address.componentsSeparatedByString(",")
        if regions.count >= 2 {
            var regionsString = ""
            for (index, region) in regions.enumerate() {
                if index > 0 {
                    regionsString = regionsString.capitalizedString + region.capitalizedString
                    if index < regions.count - 1 {
                        regionsString = regionsString + ", "
                    }
                }
            }
            if regionsString.hasPrefix(" ") {
                regionsString = regionsString.substringFromIndex(" ".endIndex)
            }
            return (regions[0], regionsString)
        }
        return (address, address)
    }
}
