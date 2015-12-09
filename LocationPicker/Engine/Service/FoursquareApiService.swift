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

final class FoursquareApiService {
    static let sharedInstance = FoursquareApiService()
    
    func searchAddress(address: String, centerCoor: CLLocationCoordinate2D, success: ([Location]) -> Void, failure: (NSError) -> Void) {
        let url = urlFromCoordinate(centerCoor, address: address)
        Alamofire.request(.GET,
            url,
            parameters: nil,
            encoding: .JSON,
            headers: nil).responseJSON { (_, response, result) -> Void in
                switch result {
                case .Failure(_, let error):
                    failure(error as NSError)
                case .Success(let json):
                    if let json = json as? [String: AnyObject] {
                        success(Location.fromFoursquareJsonArray(json))
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

extension Constants {
    struct FoursquareAPI {
        static let Place = "https://api.foursquare.com/v2/venues/search?ll=%f,%f&query=%@&oauth_token=HNUKR3RBH4ILYXT25QFJ4RPPZ3WVPMIC3IG2L51W0G5WUUSI&v=20140511"
    }
}
