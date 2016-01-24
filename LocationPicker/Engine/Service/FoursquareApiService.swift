//
//  FoursquareApiService.swift
//  CloudBike
//
//  Created by Le Tai on 7/18/15.
//  Copyright © 2015 Le Van Tai. All rights reserved.
//

import CoreLocation
import Alamofire
import Utils

public final class FoursquareApiService {
    public func searchAddress(address: String, centerCoor: CLLocationCoordinate2D, success: ([LPLocation]) -> Void, failure: (NSError) -> Void) {
        let url = urlFromCoordinate(centerCoor, address: address)
        Alamofire.request(.GET,
            url,
            parameters: nil,
            encoding: .JSON,
            headers: nil)
        .responseJSON { (response) -> Void in
            switch response.result {
            case .Failure(let error):
                failure(error)
            case .Success(let json):
                if let json = json as? [String: AnyObject] {
                    success(LPLocation.fromFoursquareJsonArray(json))
                }
            }
        }
    }
}

// MARK: - Private Methods

extension FoursquareApiService {
    private func urlFromCoordinate(coor: CLLocationCoordinate2D, address: String) -> String {
        return String(format: Constants.FoursquareAPI.Place, arguments: [coor.latitude, coor.longitude, address.removeUnicode()])
    }
}

public extension Constants {
    public struct FoursquareAPI {
        static let Place = "https://api.foursquare.com/v2/venues/search?ll=%f,%f&query=%@&oauth_token=HNUKR3RBH4ILYXT25QFJ4RPPZ3WVPMIC3IG2L51W0G5WUUSI&v=20140511"
    }
}
