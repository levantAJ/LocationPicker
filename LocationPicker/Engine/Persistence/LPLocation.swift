//
//  Location.swift
//  LocationPicker
//
//  Created by Le Tai on 12/9/15.
//  Copyright © 2015 levantAJ. All rights reserved.
//

import CoreLocation
import RealmSwift
import Utils

public enum LPLocationType: Int {
    case Unknown
    case CurrentLocation
    case Google
    case Foursquare
    case Drop
}

public final class LPLocation: Object {
    dynamic var id = ""
    dynamic var latitude = Double(0) {
        didSet {
            id = idForLocation()
        }
    }
    dynamic var longitude = Double(0) {
        didSet {
            id = idForLocation()
        }
    }
    dynamic var time = Double(0)
    dynamic var address = ""
    dynamic var name = ""
    dynamic var locationTypeRaw = LPLocationType.Unknown.rawValue
    
    public convenience init(coordinate: CLLocationCoordinate2D, address: String) {
        self.init()
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = address
        self.name = address
        self.id = idForLocation()
    }
    
    func idForLocation() -> String {
        return "\(latitude)\(longitude)"
    }
    
    public class func instanceLocations() -> [LPLocation] {
        return [currentLocation(), dropLocation()]
    }
    
    public class func currentLocation() -> LPLocation {
        let location = LPLocation()
        location.locationTypeRaw = LPLocationType.CurrentLocation.rawValue
        return location
    }
    
    public class func dropLocation() -> LPLocation {
        let location = LPLocation()
        location.locationTypeRaw = LPLocationType.Drop.rawValue
        return location
    }
    
    public func locationType() -> LPLocationType {
        guard let type = LPLocationType(rawValue: locationTypeRaw) else { return .Unknown }
        return type
    }
    
    public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["coordinate"]
    }
    
    public func update() {
        do {
            let realm = try Realm()
            try realm.write({
                self.time = NSDate().timeIntervalSince1970
                realm.add(self, update: true)
            })
        } catch let error as NSError {
            print(error)
        }
    }
    
    public class func recentlyLocations() -> [LPLocation]? {
        do {
            let realm = try Realm()
            let results = realm.objects(LPLocation).sorted("time", ascending: false)
            let locations = results.flatMap({ $0 })
            return locations.takeElements(SharedDataSource.numberOfLocationsPerAPI())
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}


//MARK: Foursquare

public extension LPLocation {
    public class func fromFoursquareJsonObject(jsonObject: [String: AnyObject]) -> LPLocation {
        let loc = LPLocation()
        if let name = jsonObject["name"] as? String {
            loc.name = name
        }
        let location = jsonObject["location"] as! [String: AnyObject]
        loc.latitude = location["lat"] as! Double
        loc.longitude = location["lng"] as! Double
        if let address = location["address"] as? String {
            loc.address = address
        }
        if loc.address.isEmpty {
            loc.address = loc.name
        }
        return loc
    }
    
    public class func fromFoursquareJsonArray(jsonArray: [String: AnyObject]) -> [LPLocation] {
        guard let response = jsonArray["response"] as? [String: AnyObject],
            venues = response["venues"] as? [[String: AnyObject]] else {
                return [LPLocation]()
        }
        var locations = [LPLocation]()
        venues.forEach {
            locations.append(LPLocation.fromFoursquareJsonObject($0))
        }
        return locations
    }
}

//MARK: Google

public extension LPLocation {
    
    enum GoogleStatus: String {
        case OK   = "OK"
        case ZERO = "ZERO_RESULTS"
    }
    
    public class func fromGoogleJsonObject(jsonObject: [String: AnyObject]) -> LPLocation {
        let loc = LPLocation()
        if let address = jsonObject["formatted_address"] as? String {
            loc.address = address
        }
        loc.name = loc.address
        let geometry = jsonObject["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: Double]
        loc.latitude = location["lat"]!
        loc.longitude = location["lng"]!
        return loc
    }
    
    public class func fromGoogleJsonArray(jsonArray: [String: AnyObject]) -> [LPLocation] {
        guard let status = jsonArray["status"] as? String where status == GoogleStatus.OK.rawValue, let results = jsonArray["results"] as? [[String: AnyObject]] else { return [LPLocation]() }
        var locations = [LPLocation]()
        results.forEach {
            locations.append(LPLocation.fromGoogleJsonObject($0))
        }
        return locations
    }
}

//MARK: Vietbando

public extension LPLocation {
    public class func fromVietBanDoJsonArray(jsonArray: [String: AnyObject]) -> [LPLocation] {
        guard let list = jsonArray["List"] as? [[String: AnyObject]] else { return [LPLocation]() }
        var locations = [LPLocation]()
        list.forEach {
            locations.append(LPLocation.fromVietBanDoJsonObject($0))
        }
        return locations
    }
    
    public class func fromVietBanDoJsonObject(jsonObject: [String: AnyObject]) -> LPLocation {
        let loc = LPLocation()
        var address = ""
        if let number = jsonObject["Number"] as? String {
            address = "\(address)\(number)"
        }
        if let street = jsonObject["Street"] as? String {
            address = "\(address), \(street)"
        }
        if let ward = jsonObject["Ward"] as? String {
            address = "\(address), \(ward)"
        }
        if let district = jsonObject["District"] as? String {
            address = "\(address), \(district)"
        }
        if let province = jsonObject["Province"] as? String {
            address = "\(address), \(province)"
        }
        loc.address = address
        if let latitude = jsonObject["Latitude"] as? Double {
            loc.latitude = latitude
        }
        if let longitude = jsonObject["Longitude"] as? Double {
            loc.longitude = longitude
        }
        if let name = jsonObject["Name"] as? String {
            loc.name = name
        }
        return loc
    }
}
