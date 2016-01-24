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
    public func searchAddress(address: String, topLeftCoordinate: CLLocationCoordinate2D, bottomRightCoordinate: CLLocationCoordinate2D, success: ([LPLocation]) -> Void, failure: (NSError) -> Void) {
        guard let url = SharedDataSource.vietbandoAPI()?.absoluteString, key = SharedDataSource.vietbandoKey() else { return }
        Alamofire.request(.GET,
            url,
            parameters: [
                "IsOrder": true,
                "Keyword": address,
                "Lx": topLeftCoordinate.latitude,
                "Ly": topLeftCoordinate.longitude,
                "Rx": bottomRightCoordinate.latitude,
                "Ry": bottomRightCoordinate.longitude,
                "Page":1,
                "PageSize":20
            ],
            encoding: .JSON,
            headers: [
                "RegisterKey": key,
                "Content-Type": "application/json"
            ])
            .responseJSON { (response) -> Void in
                switch response.result {
                case .Failure(let error):
                    failure(error)
                case .Success(let json):
                    if let json = json as? [String: AnyObject] {
                        success(LPLocation.fromGoogleJsonArray(json))
                    }
                }
        }
    }
}
