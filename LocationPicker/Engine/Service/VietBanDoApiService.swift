//
//  VietBanDoApiService.swift
//  LocationPicker
//
//  Created by Le Tai on 1/24/16.
//  Copyright © 2016 levantAJ. All rights reserved.
//

import Alamofire
import ObjectMapper
import CoreLocation
import Utils

public final class VietBanDoApiService {
    public static let sharedInstance = VietBanDoApiService()
    
    public func searchAddress(address: String, topLeftCoordinate: CLLocationCoordinate2D, bottomRightCoordinate: CLLocationCoordinate2D, success: ([LPLocation]) -> Void, failure: (NSError) -> Void) {
        guard let key = SharedDataSource.vietbandoKey() else { return }
        Alamofire.request(.POST, Constants.VietBanDoApiService.API,
            parameters: [
                "IsOrder": true,
                "Keyword": address,
                "Lx": topLeftCoordinate.latitude,
                "Ly": topLeftCoordinate.longitude,
                "Rx": bottomRightCoordinate.latitude,
                "Ry": bottomRightCoordinate.longitude,
                "Page": 1,
                "PageSize": SharedDataSource.numberOfLocationsPerAPI()
            ],
            encoding: .JSON,
            headers: [
                "RegisterKey": key
            ])
            .responseJSON { (response) -> Void in
                switch response.result {
                case .Failure(let error):
                    failure(error)
                case .Success(let json):
                    if let json = json as? [String: AnyObject] {
                        success(LPLocation.fromVietBanDoJsonArray(json))
                    }
                }
        }
    }
}

extension Constants {
    struct VietBanDoApiService {
        static let API = "http://developers.vietbando.com/V2/service/PartnerPortalService.svc/rest/SearchAll"
    }
}
