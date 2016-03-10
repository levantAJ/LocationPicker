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
import Debouncer

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
    private let debouncer = Debouncer(delay: 0.2)
    
    override init() {
        locations.value?[SearchResultType.Instance] = [LPLocation]()
        locations.value?[SearchResultType.Recently] = [LPLocation]()
        locations.value?[SearchResultType.Remote] = [LPLocation]()
        debouncer.invalidate()
    }
    
    override func removeListeners() {
        super.removeListeners()
        locations.removeListener()
        address.removeListener()
    }
    
    func searchAddress(address: String, centerCoor: CLLocationCoordinate2D, topLeftCoordinate: CLLocationCoordinate2D, bottomRightCoordinate: CLLocationCoordinate2D) {
        debouncer.dispatch {
            self.locations.value?[SearchResultType.Remote] = [LPLocation]()
            if !address.isEmpty {
                let digits = NSCharacterSet.decimalDigitCharacterSet()
                if let firstCharacter = address.unicodeScalars.first where                     digits.longCharacterIsMember(firstCharacter.value)  {
                    self.searchByVietBanDo(address, topLeftCoordinate: topLeftCoordinate, bottomRightCoordinate: bottomRightCoordinate)
                    self.searchByGoogle(address)
                    self.searchByFoursquare(address, centerCoor: centerCoor)
                } else {
                    self.searchByFoursquare(address, centerCoor: centerCoor)
                    self.searchByGoogle(address)
                    self.searchByVietBanDo(address, topLeftCoordinate: topLeftCoordinate, bottomRightCoordinate: bottomRightCoordinate)
                    
                }
            } else {
                self.locations.value = self.instancelocationsFromRemoteLocations([LPLocation]())
            }
        }
    }
    
    func searchByGoogle(address: String) {
        GoogleApiService.sharedInstance.searchAddress(address, success: { [weak self] (locations) -> Void in
            self?.locations.value = self?.instancelocationsFromRemoteLocations(locations.takeElements(SharedDataSource.numberOfLocationsPerAPI()))
            self?.handleError(nil)
            }, failure: { [weak self] (error) -> Void in
                self?.handleError(error)
            })
    }
    
    func searchByFoursquare(address: String, centerCoor: CLLocationCoordinate2D) {
        FoursquareApiService.sharedInstance.searchAddress(address, centerCoor: centerCoor, success: { [weak self] (locations) -> Void in
            self?.locations.value = self?.instancelocationsFromRemoteLocations(locations.takeElements(SharedDataSource.numberOfLocationsPerAPI()))
            self?.handleError(nil)
            }, failure: { [weak self] (error) -> Void in
                self?.handleError(error)
            })
    }
    
    func searchByVietBanDo(address: String, topLeftCoordinate: CLLocationCoordinate2D, bottomRightCoordinate: CLLocationCoordinate2D ) {
        VietBanDoApiService.sharedInstance.searchAddress(address, topLeftCoordinate: topLeftCoordinate, bottomRightCoordinate: bottomRightCoordinate, success: { [weak self] (locations) -> Void in
            self?.locations.value = self?.instancelocationsFromRemoteLocations(locations.takeElements(SharedDataSource.numberOfLocationsPerAPI()))
            self?.handleError(nil)
            }, failure: { [weak self] (error) -> Void in
                self?.handleError(error)
            })
    }
    
    func addressFromCoordinate(coordinate: CLLocationCoordinate2D) {
        GoogleApiService().addressByCoordinate(coordinate, success: { [weak self] (address) -> Void in
            self?.address.value = address
            self?.handleError(nil)
            }) { [weak self] (error) -> Void in
                self?.address.value = NSLocalizedString("Could not get address, try again!", comment: "")
                self?.handleError(error)
        }
    }
    
    private func instancelocationsFromRemoteLocations(remoteLocations: [LPLocation]) -> OrderedDictionary<SearchResultType, [LPLocation]> {
        var currentRemoteLocations = [LPLocation]()
        if let locations = locations.value?[SearchResultType.Remote] {
            currentRemoteLocations = locations
        }
        var results = OrderedDictionary<SearchResultType, [LPLocation]>()
        results[SearchResultType.Instance] = LPLocation.instanceLocations()
        results[SearchResultType.Recently] = LPLocation.recentlyLocations() ?? []
        results[SearchResultType.Remote] = currentRemoteLocations + remoteLocations
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
