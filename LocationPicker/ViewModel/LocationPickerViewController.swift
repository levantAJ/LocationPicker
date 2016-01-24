//
//  LocationPickerViewController.swift
//  LocationPicker
//
//  Created by Le Tai on 7/21/15.
//  Copyright © 2015 Le Van Tai. All rights reserved.
//

import UIKit
import MapKit
import Utils

public protocol LocationPickerViewControllerDelegate: class {
    func locationPickerViewController(controller: LocationPickerViewController, seletedCoordinate coordinate: CLLocationCoordinate2D, selectedAddress address: String)
}

public final class LocationPickerViewController: UIViewController {
    
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var currentLocationButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentLocationButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var pinView: MKPinAnnotationView!
    var calloutView: LocationCalloutView!
    var locationPickerViewModel = LocationPickerViewModel()
    
    lazy var ellipse: UIBezierPath = { [weak self] in
        let ellipse = UIBezierPath(ovalInRect: CGRect(origin: CGPoint.zero, size: Constants.LocationPickerViewController.PinViewFootSize))
        return ellipse
        }()
    
    
    lazy var ellipsisLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.bounds = CGRect(origin: CGPoint.zero, size: Constants.LocationPickerViewController.PinViewFootSize)
        layer.path = self.ellipse.CGPath
        layer.fillColor = UIColor.grayColor().CGColor
        layer.fillRule = kCAFillRuleNonZero
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 1.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.grayColor().CGColor
        return layer
    }()
    
    public weak var delegate: LocationPickerViewControllerDelegate?
    public var coordinate: CLLocationCoordinate2D?
    public var address: String?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
        setupCurrentLocationButton()
        setupMapView()
        setupPinView()
        setupCalloutView()
        setupSearchBar()
        setupTableView()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let center = CGPoint(x: mapView.frame.width/2, y: mapView.frame.height/2 + pinView.frame.height - Constants.LocationPickerViewController.PinViewSpace)
        pinView.center = CGPointMake(center.x + Constants.LocationPickerViewController.PinViewSpace, center.y - pinView.frame.height/2 + Constants.LocationPickerViewController.PinTopPadding)
        ellipsisLayer.position = center
        calloutView.center = CGPointMake(center.x, center.y - calloutView.frame.height - Constants.LocationPickerViewController.PinTopPadding)
        guard let coordinate = coordinate where !coordinate.isZero else { return }
        mapView.gotoLocation(coordinate)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.locationPickerViewModel.addressFromCoordinate(coordinate)
            self.calloutView.show()
        }
    }
    
    deinit {
        locationPickerViewModel.removeListeners()
    }
    
    private func setupTableView() {
        tableView.hidden = true
        tableView.delegate = self
        tableView.dataSource = self
        let tap = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        view.bringSubviewToFront(tableView)
    }
    
    private func setupCalloutView() {
        calloutView = LocationCalloutView.standardView()
        calloutView.delegate = self
        view.addSubview(calloutView)
    }
    
    private func setupViewModel() {
        locationPickerViewModel.locations.onChange { [weak self] (value) -> Void in
            self?.tableView.reloadData()
            self?.tableView.hidden = false
        }
        locationPickerViewModel.address.onChange { [weak self] (value) -> Void in
            guard let weakSelf = self else { return }
            weakSelf.calloutView.address = value
        }
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.Follow, animated: true)
    }
    
    private func setupPinView() {
        pinView = MKPinAnnotationView()
        pinView.pinColor = .Green
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.enableSearchBar()
        searchBar.setTextColor(UIColor.whiteColor())
        searchBar.setPlaceholderTextColor(UIColor.whiteColor())
    }
    
    private func setupCurrentLocationButton() {
        currentLocationButton.setImage(LocationPicker.sharedInstance.dataSource.currentLocationImage(), forState: .Normal)
        currentLocationButtonWidthConstraint.constant = LocationPicker.sharedInstance.dataSource.currentLocationSize().width
        currentLocationButtonHeightConstraint.constant = LocationPicker.sharedInstance.dataSource.currentLocationSize().height
        if LocationPicker.sharedInstance.dataSource.currentLocationIsCircle() {
            currentLocationButton.addRadius(currentLocationButtonWidthConstraint.constant/2)
        } else {
            currentLocationButton.addRadius()
        }
    }
}

//MARK: Map delegate

extension LocationPickerViewController: MKMapViewDelegate {
    public func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.pinView.center = CGPointMake(self.pinView.center.x, self.pinView.center.y - Constants.LocationPickerViewController.PinAnimatedSpace)
            self.calloutView.center = CGPointMake(self.calloutView.center.x, self.calloutView.center.y - Constants.LocationPickerViewController.PinAnimatedSpace)
            }) { (finished) -> Void in
                if finished {
                    self.calloutView.hide()
                }
        }
    }
    public func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.pinView.center = CGPointMake(self.pinView.center.x, self.pinView.center.y + Constants.LocationPickerViewController.PinAnimatedSpace)
            self.calloutView.center = CGPointMake(self.calloutView.center.x, self.calloutView.center.y + Constants.LocationPickerViewController.PinAnimatedSpace)
            }) { (finished) -> Void in
                if finished {
                    let coordinate = mapView.convertPoint(self.ellipsisLayer.position, toCoordinateFromView: mapView)
                    self.locationPickerViewModel.addressFromCoordinate(coordinate)
                    self.calloutView.show()
                }
        }
    }
}

// MARK: - User interactions

extension LocationPickerViewController {
    func tableViewTapped() {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func currentLocationButtonTapped(button: UIButton) {
        mapView.setUserTrackingMode(.Follow, animated: true)
    }
}

//MARK: table view data source

extension LocationPickerViewController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let semaphores = locationPickerViewModel.locations.value {
            return semaphores.count
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationPickerViewModel.numberOfLocationsInSection(section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.LocationPickerViewController.DropMapSeachCell, forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFontOfSize(15)
        guard let location = locationPickerViewModel.locationAtIndexPath(indexPath) else { return cell }
        switch location.locationType() {
        case .CurrentLocation:
            cell.textLabel?.text = NSLocalizedString("Your current location", comment: "")
        case .Drop:
            cell.textLabel?.text = NSLocalizedString("Choose on map", comment: "")
        default:
            cell.textLabel?.text = location.address
            cell.detailTextLabel?.text = location.name
        }
        if let type = SearchResultType(rawValue: indexPath.section) {
            cell.imageView?.image = type.locationImage(indexPath.row)
        }
        return cell
    }
}

//MARK: Table View Delegate

extension LocationPickerViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchBar.resignFirstResponder()
        tableView.hidden = true
        guard let location = locationPickerViewModel.locationAtIndexPath(indexPath) else { return }
        switch location.locationType() {
        case .CurrentLocation:
            location.latitude = mapView.userLocation.coordinate.latitude
            location.longitude = mapView.userLocation.coordinate.longitude
            mapView.setUserTrackingMode(.Follow, animated: true)
        case .Drop:
            location.latitude = mapView.centerCoordinate.latitude
            location.longitude = mapView.centerCoordinate.longitude
            mapView.gotoLocation(mapView.centerCoordinate)
        default:
            mapView.gotoLocation(location.coordinate())
        }
        calloutView.show()
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return locationPickerViewModel.numberOfLocationsInSection(section) == 0 ? "" : SearchResultType(rawValue: section)?.localizedString()
    }
}

// MARK: - UISearchBarDelegate

extension LocationPickerViewController: UISearchBarDelegate {
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.hidden = false
        guard !searchText.isEmpty else { return }
        locationPickerViewModel.searchAddress(searchText, centerCoor: mapView.centerCoordinate, topLeftCoordinate: mapView.topLeftCoordinate(), bottomRightCoordinate: mapView.bottomRightCoordinate())
    }
    
    public func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        tableView.hidden = false
        locationPickerViewModel.searchAddress("", centerCoor: mapView.centerCoordinate, topLeftCoordinate: mapView.topLeftCoordinate(), bottomRightCoordinate: mapView.bottomRightCoordinate())
        calloutView.hide()
        return true
    }
}

// MARK: - LocationCalloutViewDelegate

extension LocationPickerViewController: LocationCalloutViewDelegate {
    func locationCalloutViewDidTap() {
        guard let address = calloutView.address else { return }
        let coordinate = mapView.convertPoint(self.ellipsisLayer.position, toCoordinateFromView: mapView)
        delegate?.locationPickerViewController(self, seletedCoordinate: coordinate, selectedAddress: address)
        let location = LPLocation(coordinate: coordinate, address: address)
        location.update()
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension Constants {
    struct LocationPickerViewController {
        static let PinTopPadding = CGFloat(4)
        static let PinAnimatedSpace = CGFloat(15)
        static let PinViewSpace = CGFloat(8.1)
        static let PinViewFootSize = CGSize(width: 10, height: 5)
        static let DropMapSeachCell = "DropMapSeachCell"
        static let Identifier = "LocationPickerViewController"
    }
}