//
//  GoogleApiService.swift
//  CloudBike
//
//  Created by Le Tai on 7/18/15.
//  Copyright © 2015 Le Van Tai. All rights reserved.
//

import Alamofire
import ObjectMapper
import CoreLocation
import Utils

public final class GoogleApiService {
    public static let sharedInstance = GoogleApiService()
    
    public func searchAddress(address: String,
        success: ([Location]) -> Void,
        failure: ((NSError?) -> Void)?) {
            let url = urlWithAddress(address)
            Alamofire.request(.GET,
                url,
                parameters: nil,
                encoding: .JSON,
                headers: nil)
            .responseJSON { (response) -> Void in
                switch response.result {
                case .Failure(let error):
                    failure?(error)
                case .Success(let json):
                    if let json = json as? [String: AnyObject] {
                        success(Location.fromGoogleJsonArray(json))
                    } else {
                        failure?(APIError.NoBodyFound.foundationError())
                    }
                }
            }
    }
    
    public func addressByCoordinate(coor: CLLocationCoordinate2D,
        success: (String) -> Void,
        failure: ((NSError) -> Void)?) {
            let url = urlWithCoordinate(coor)
            Alamofire.request(.GET,
                url,
                parameters: nil,
                encoding: .JSON,
                headers: nil)
            .responseJSON { (response) -> Void in
                switch response.result {
                case .Failure(let error):
                    failure?(error)
                case .Success(let json):
                    if let json = json as? [String: AnyObject] {
                        let locations = Location.fromGoogleJsonArray(json)
                        if locations.count != 0 {
                            success(locations[0].address)
                        } else {
                            failure?(APIError.NoBodyFound.foundationError())
                        }
                    }
                }
            }
    }
    
    public func navigateFrom(fromCoordiante: CLLocationCoordinate2D = CLLocationCoordinate2D(),
        toCoordiante: CLLocationCoordinate2D = CLLocationCoordinate2D(),
        waypoints: [CLLocationCoordinate2D] = [CLLocationCoordinate2D](),
        success: (String) -> Void,
        failure: ((NSError?) -> Void)?) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
                guard let url = NSURL(string: self.urlFromCoordinate(fromCoordiante, toCoordinate: toCoordiante, waypoints: waypoints)) else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        failure?(APIError.Unspecified.foundationError())
                    })
                    return
                }
                Alamofire.request(.GET,
                    url,
                    parameters: nil,
                    encoding: .URL,
                    headers: nil)
                .responseString(completionHandler: { (response) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        switch response.result {
                        case .Success(var string):
                            let data = string.dataUsingEncoding(NSUTF8StringEncoding)
                            string = String(data: data!, encoding: NSUTF8StringEncoding)!
                            success(string)
                        case .Failure(let error):
                            failure?(error)
                        }
                    })
                })
            }
    }
    
    private func urlWithAddress(address: String) -> String {
        return "\(Constants.GoogleAPI.Place)\(address.removeUnicode())"
    }
    
    private func urlWithCoordinate(coor: CLLocationCoordinate2D) -> String {
        return String(format: Constants.GoogleAPI.Address, arguments: [coor.latitude, coor.longitude, "en"])
    }
    
    private func urlFromCoordinate(fromCoordiante: CLLocationCoordinate2D, toCoordinate: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D]) -> String {
        if waypoints.count == 0 {
            return String(format: Constants.GoogleAPI.Route, arguments: [fromCoordiante.latitude, fromCoordiante.longitude, toCoordinate.latitude, toCoordinate.longitude])
        } else {
            return String(format: Constants.GoogleAPI.RouteHasWaypoints, arguments: [fromCoordiante.latitude, fromCoordiante.longitude, toCoordinate.latitude, toCoordinate.longitude, waypointsFromArray(waypoints)])
        }
    }
    
    private func waypointsFromArray(waypoints: [CLLocationCoordinate2D]) -> String {
        let waypointsString = NSMutableString(string: "")
        for waypoint in waypoints {
            waypointsString.appendFormat("%f,%f|", waypoint.latitude, waypoint.longitude)
        }
        
        if waypointsString.length > 0 {
            return String(waypointsString.substringToIndex(waypointsString.length - 2)).removeUnicode()
        }
        return String(waypointsString)
    }
}

public extension Constants {
    public struct GoogleAPI {
        static let NumberAceptedWaypoints = 6
        static let Place = "https://maps.googleapis.com/maps/api/geocode/json?address="
        static let Address = "http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false&language=%@"
        static let Route = "https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=driving"
        static let RouteHasWaypoints = "https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=driving&waypoints=%@"
    }
}
