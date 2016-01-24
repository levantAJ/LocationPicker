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

public enum SearchResultType: Int {
    case Instance
    case Recently
    case Remote
    
    func localizedString() -> String {
        switch self {
        case .Instance:
            return ""
        case .Recently:
            return NSLocalizedString("Recently", comment: "")
        case .Remote:
            return NSLocalizedString("Remote", comment: "")
        }
    }
    
    func locationImage(row: Int) -> UIImage {
        switch self {
        case .Instance:
            if row == 0 {
                return SharedDataSource.currentLocationImage().imageToSize(SharedDataSource.iconSize())
            } else {
                return SharedDataSource.locationImage().imageToSize(SharedDataSource.iconSize())
            }
        case .Recently:
            return SharedDataSource.recentlyImage().imageToSize(SharedDataSource.iconSize())
        case .Remote:
            return SharedDataSource.locationImage().imageToSize(SharedDataSource.iconSize())
        }
    }
}

final class LocationPickerViewModel: BaseViewModel {
    var locations = Observable(value: OrderedDictionary<SearchResultType, [LPLocation]>())
    var address = Observable(value: "")
    
    override init() {
        locations.value?[SearchResultType.Instance] = [LPLocation]()
        locations.value?[SearchResultType.Recently] = [LPLocation]()
        locations.value?[SearchResultType.Remote] = [LPLocation]()
    }
    
    override func removeListeners() {
        super.removeListeners()
        locations.removeListener()
        address.removeListener()
    }
    
    func searchAddress(address: String, coordinate: CLLocationCoordinate2D) {
        if !address.isEmpty {
            if Array(arrayLiteral: address)[0].tryParseInt() {
                FoursquareApiService.sharedInstance.searchAddress(address, centerCoor: coordinate, success: { [weak self] (locations) -> Void in
                    self?.locations.value = self?.instancelocationsFromSemaphore(locations)
                    self?.handleError(nil)
                    }, failure: { [weak self] (error) -> Void in
                        self?.handleError(error)
                })
            } else {
                GoogleApiService.sharedInstance.searchAddress(address, success: { [weak self] (locations) -> Void in
                    self?.locations.value = self?.instancelocationsFromSemaphore(locations)
                    self?.handleError(nil)
                    }, failure: { [weak self] (error) -> Void in
                        self?.handleError(error)
                })
            }
        } else {
            locations.value = instancelocationsFromSemaphore([LPLocation]())
        }
    }
    
    func addressFromCoordinate(coordinate: CLLocationCoordinate2D) {
        GoogleApiService.sharedInstance.addressByCoordinate(coordinate, success: { [weak self] (address) -> Void in
            self?.address.value = address
            self?.handleError(nil)
            }) { [weak self] (error) -> Void in
                self?.address.value = NSLocalizedString("Could not get address, try again!", comment: "")
                self?.handleError(error)
        }
    }
    
    private func instancelocationsFromSemaphore(locations: [LPLocation]) -> OrderedDictionary<SearchResultType, [LPLocation]> {
        var results = OrderedDictionary<SearchResultType, [LPLocation]>()
        results[SearchResultType.Instance] = LPLocation.instanceLocations()
        results[SearchResultType.Recently] = LPLocation.recentlyLocations() ?? []
        results[SearchResultType.Remote] = locations
        return results
    }
    
    func locationAtIndexPath(indexPath: NSIndexPath) -> LPLocation? {
        guard let locations = locations.value, array = locations[indexPath.section] where indexPath.row < array.count else { return nil }
        return array[indexPath.row]
    }
    
    func numberOfLocationsInSection(section: Int) -> Int {
        guard let locations = locations.value, count = locations[section]?.count else { return 0 }
        return count
    }
}
