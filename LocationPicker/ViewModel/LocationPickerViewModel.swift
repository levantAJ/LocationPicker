//
//  LocationPickerViewModel.swift
//  LocationPicker
//
//  Created by Le Tai on 9/10/15.
//  Copyright © 2015 Le Van Tai. All rights reserved.
//

import CoreLocation
import Observable
import Utils

final class LocationPickerViewModel {
    var locations = Observable(value: ["": [Location](), "RESULTS": [Location]()])
    var address = Observable(value: "")
    var error = Observable(value: APIError.Unspecified.foundationError())
    
    func removeListeners() {
        error.removeListener()
        locations.removeListener()
        address.removeListener()
    }
    
    func searchAddress(address: String, coordinate: CLLocationCoordinate2D) {
        if !address.isEmpty {
            if Array(arrayLiteral: address)[0].tryParseInt() {
                FoursquareApiService.sharedInstance.searchAddress(address, centerCoor: coordinate, success: { (locations) -> Void in
                    self.locations.value = self.instancelocationsFromSemaphore(locations)
                    self.error.value = nil
                    }, failure: { (error) -> Void in
                        self.error.value = error
                })
            } else {
                GoogleApiService.sharedInstance.searchAddress(address, success: { (locations) -> Void in
                    self.locations.value = self.instancelocationsFromSemaphore(locations)
                    self.error.value = nil
                    }, failure: { (error) -> Void in
                        self.error.value = error
                })
            }
        } else {
            locations.value = instancelocationsFromSemaphore([Location]())
        }
    }
    
    func addressFromCoordinate(coordinate: CLLocationCoordinate2D) {
        GoogleApiService.sharedInstance.addressByCoordinate(coordinate, success: { [weak self] (address) -> Void in
            self?.address.value = address
            self?.error.value = nil
            }) { [weak self] (error) -> Void in
                self?.address.value = NSLocalizedString("Could not get address, try again!", comment: "")
                self?.error.value = error
        }
    }
    
    private func instancelocationsFromSemaphore(locations: [Location]) -> [String: [Location]] {
        return [
            "": Location.instanceLocations(),
            "RESULTS": locations
        ]
    }
    
    func locationAtIndexPath(indexPath: NSIndexPath) -> Location? {
        if let locations = locations.value,
            array = locations.valueAtIndex(indexPath.section) as? [Location]
            where indexPath.row < array.count {
                return array[indexPath.row]
        }
        return nil
    }
}
