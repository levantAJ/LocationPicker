//
//  Location.swift
//  LocationPicker
//
//  Created by Le Tai on 12/9/15.
//  Copyright © 2015 levantAJ. All rights reserved.
//

import CoreLocation

enum LocationType {
    case Unknown
    case CurrentLocation
    case Google
    case Foursquare
    case Drop
}

public final class Location {
    
    var coordinate = CLLocationCoordinate2D()
    var address = ""
    var name = ""
    var locationType = LocationType.Unknown
    
    class func instanceLocations() -> [Location] {
        return [currentLocation(), dropLocation()]
    }
    
    class func currentLocation() -> Location {
        let location = Location()
        location.locationType = .CurrentLocation
        return location
    }
    
    class func dropLocation() -> Location {
        let location = Location()
        location.locationType = .Drop
        return location
    }
}


//MARK: Foursquare

extension Location {
    class func fromFoursquareJsonObject(jsonObject: [String: AnyObject]) -> Location {
        let loc = Location()
        if let name = jsonObject["name"] as? String {
            loc.name = name
        }
        let location = jsonObject["location"] as! [String: AnyObject]
        loc.coordinate = CLLocationCoordinate2DMake(location["lat"] as! Double, location["lng"] as! Double)
        if let address = location["address"] as? String {
            loc.address = address
        }
        if loc.address.isEmpty {
            loc.address = loc.name
        }
        return loc
    }
    
    class func fromFoursquareJsonArray(jsonArray: [String: AnyObject]) -> [Location] {
        guard let response = jsonArray["response"] as? [String: AnyObject],
            venues = response["venues"] as? [[String: AnyObject]] else {
                return [Location]()
        }
        var locations = [Location]()
        for item in venues {
            locations.append(Location.fromFoursquareJsonObject(item))
        }
        return locations
    }
}

//MARK: Google

extension Location {
    
    enum GoogleStatus: String {
        case OK   = "OK"
        case ZERO = "ZERO_RESULTS"
    }
    
    class func fromGoogleJsonObject(jsonObject: [String: AnyObject]) -> Location {
        let loc = Location()
        if let address = jsonObject["formatted_address"] as? String {
            loc.address = address
        }
        loc.name = loc.address
        let geometry = jsonObject["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: Double]
        loc.coordinate = CLLocationCoordinate2DMake(location["lat"]!, location["lng"]!)
        return loc
    }
    
    class func fromGoogleJsonArray(jsonArray: [String: AnyObject]) -> [Location] {
        guard let status = jsonArray["status"] as? String where status == GoogleStatus.OK.rawValue, let results = jsonArray["results"] as? [[String: AnyObject]] else {
            return [Location]()
        }
        var locations = [Location]()
        for item in results {
            locations.append(Location.fromGoogleJsonObject(item))
        }
        return locations
    }
}
