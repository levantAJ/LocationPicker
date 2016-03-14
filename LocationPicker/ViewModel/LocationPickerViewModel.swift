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
    case Remote
    case Instance
    case Recently
    
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
        case .Remote:
            return SharedDataSource.locationImage().imageToSize(SharedDataSource.iconSize())
        case .Instance:
            if row == 0 {
                return SharedDataSource.currentLocationImage().imageToSize(SharedDataSource.iconSize())
            } else {
                return SharedDataSource.locationImage().imageToSize(SharedDataSource.iconSize())
            }
        case .Recently:
            return SharedDataSource.recentlyImage().imageToSize(SharedDataSource.iconSize())
        }
    }
}

final class LocationPickerViewModel: BaseViewModel {
    var locations = Observable(value: OrderedDictionary<SearchResultType, [LPLocation]>())
    var address = Observable(value: "")
    var firstCharacterIsNumber = false
    private let debouncer = Debouncer(delay: 0.2)
    
    override init() {
        locations.value?[SearchResultType.Remote] = [LPLocation]()
        locations.value?[SearchResultType.Instance] = [LPLocation]()
        locations.value?[SearchResultType.Recently] = [LPLocation]()
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
                    self.firstCharacterIsNumber = true
                } else {
                    self.firstCharacterIsNumber = false
                }
                self.searchByFoursquare(address, centerCoor: centerCoor)
                self.searchByGoogle(address, topLeftCoordinate: topLeftCoordinate, bottomRightCoordinate: bottomRightCoordinate)
                self.searchByVietBanDo(address, topLeftCoordinate: topLeftCoordinate, bottomRightCoordinate: bottomRightCoordinate)
            } else {
                self.locations.value = self.instancelocationsFromRemoteLocations([LPLocation]())
            }
        }
    }
    
    func searchByGoogle(address: String, topLeftCoordinate: CLLocationCoordinate2D, bottomRightCoordinate: CLLocationCoordinate2D) {
        GoogleApiService.sharedInstance.searchAddress(address, topLeftCoordinate: topLeftCoordinate, bottomRightCoordinate: bottomRightCoordinate, success: { [weak self] (locations) -> Void in
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
    
    func sortResultBySearchMethod(finalResult: [LPLocation]) -> [LPLocation] {
        var results = [LPLocation]()
        var resultByGoogle = [LPLocation]()
        var resultByFourSquare = [LPLocation]()
        var resultByVietBanDo = [LPLocation]()
        for result in finalResult {
            switch result.locationTypeValue {
            case .Google:
                resultByGoogle.append(result)
            case .Foursquare:
                resultByFourSquare.append(result)
            case .VietBanDo:
                resultByVietBanDo.append(result)
            default:
                break
            }
        }
        if firstCharacterIsNumber {
            results = addObjectFromArray(resultByVietBanDo, secondArray: resultByGoogle, thirdArray: resultByFourSquare)
        } else {
            results = addObjectFromArray(resultByFourSquare, secondArray: resultByGoogle, thirdArray: resultByVietBanDo)
        }
        return results
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
        let remoteResults = currentRemoteLocations + remoteLocations
        results[SearchResultType.Remote] = sortResultBySearchMethod(remoteResults)
        results[SearchResultType.Instance] = LPLocation.instanceLocations()
        results[SearchResultType.Recently] = LPLocation.recentlyLocations() ?? []
        return results
    }
    
    private func addObjectFromArray(firstArray: [LPLocation], secondArray: [LPLocation], thirdArray: [LPLocation]) -> [LPLocation]{
        var finalResult = [LPLocation]()
        for item in firstArray {
            finalResult.append(item)
        }
        for item in secondArray {
            finalResult.append(item)
        }
        for item in thirdArray {
            finalResult.append(item)
        }
        return finalResult
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
