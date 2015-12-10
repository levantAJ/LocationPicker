//
//  LocationCalloutView.swift
//  PinBike
//
//  Created by Le Tai on 12/4/15.
//  Copyright © 2015 Le Van Tai. All rights reserved.
//

import UIKit
import Utils

protocol LocationCalloutViewDelegate: class {
    func locationCalloutViewDidTap()
}

final class LocationCalloutView: UIView {
    private var wrapperView: UIView!
    private var selectLocationButton: UIButton!
    private var addressLabel: UILabel!
    private var loadingView: UIActivityIndicatorView!
    private var bubbleImageView: UIImageView!
    
    var address: String? {
        didSet {
            if let address = address where !address.isEmpty {
                addressLabel.text = address
            } else {
                addressLabel.text = NSLocalizedString("Could not get address, try again!", comment: "")
            }
            addressLabel.sizeToFit()
            var addressFrame = addressLabel.frame
            addressFrame.size.width = min(addressFrame.width, frame.width - 2*Constants.LocationCalloutView.Padding)
            addressLabel.frame = addressFrame
            loadingView.stopAnimating()
        }
    }
    
    weak var delegate: LocationCalloutViewDelegate?
    
    static let sharedInstance = LocationCalloutView()

    class func standardView() -> LocationCalloutView {
        sharedInstance.wrapperView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.LocationCalloutView.Width, height: 0))
        sharedInstance.wrapperView.addRadius(Constants.LocationCalloutView.Padding)
        sharedInstance.wrapperView.backgroundColor = UIColor.whiteColor()
        sharedInstance.addSubview(sharedInstance.wrapperView)
        
        sharedInstance.selectLocationButton = UIButton(type: .System)
        sharedInstance.selectLocationButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Select this location", comment: ""), attributes: [
            NSFontAttributeName: UIFont.semiboldFontWithSize(15)!
            ]), forState: .Normal)
        sharedInstance.selectLocationButton.sizeToFit()
        sharedInstance.selectLocationButton.addTarget(sharedInstance, action: "selectLocationButtonTapped:", forControlEvents: .TouchUpInside)
        sharedInstance.selectLocationButton.frame = CGRect(origin: CGPoint(x: Constants.LocationCalloutView.Padding, y: 0), size: sharedInstance.selectLocationButton.frame.size)
        sharedInstance.wrapperView.addSubview(sharedInstance.selectLocationButton)
        
        sharedInstance.addressLabel = UILabel()
        sharedInstance.addressLabel.text = Constants.LocationCalloutView.GettingAddress
        sharedInstance.addressLabel.sizeToFit()
        sharedInstance.addressLabel.frame = CGRect(origin: CGPoint(x: sharedInstance.selectLocationButton.frame.minX, y: sharedInstance.selectLocationButton.frame.maxY - Constants.LocationCalloutView.AddressLabelPadding), size: sharedInstance.addressLabel.frame.size)
        sharedInstance.addressLabel.font = UIFont.regularFontWithSize(12)
        sharedInstance.wrapperView.addSubview(sharedInstance.addressLabel)
        
        sharedInstance.wrapperView.frame = CGRect(origin: sharedInstance.wrapperView.frame.origin, size: CGSize(width: sharedInstance.wrapperView.frame.width, height: sharedInstance.addressLabel.frame.maxY + Constants.LocationCalloutView.AddressLabelPadding))
        
        sharedInstance.loadingView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        sharedInstance.loadingView.center = CGPoint(x: sharedInstance.wrapperView.frame.width - sharedInstance.loadingView.frame.width, y: sharedInstance.wrapperView.frame.height/2)
        sharedInstance.loadingView.startAnimating()
        sharedInstance.wrapperView.addSubview(sharedInstance.loadingView)
        
        sharedInstance.bubbleImageView = UIImageView(image: UIImage(named: "map-callout-leg", inBundle: LocationPicker.frameworkBundle(), compatibleWithTraitCollection: nil))
        sharedInstance.bubbleImageView.sizeToFit()
        sharedInstance.bubbleImageView.center = CGPoint(x: sharedInstance.wrapperView.frame.width/2, y: sharedInstance.wrapperView.frame.height + sharedInstance.bubbleImageView.frame.height/2 - 2)
        sharedInstance.addSubview(sharedInstance.bubbleImageView)
        
        sharedInstance.backgroundColor = UIColor.clearColor()
        sharedInstance.clipsToBounds = true
        sharedInstance.frame = CGRect(origin: sharedInstance.wrapperView.frame.origin, size: CGSize(width: sharedInstance.wrapperView.frame.width, height: sharedInstance.bubbleImageView.frame.maxY))
        return sharedInstance
    }
    
    func show() {
        self.loadingView.startAnimating()
        UIView.animateWithDuration(0.25) { () -> Void in
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.alpha = 0
            }) { (finished) -> Void in
                self.addressLabel.text = Constants.LocationCalloutView.GettingAddress
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.locationCalloutViewDidTap()
    }
}

//MARK: Users Intercations

extension LocationCalloutView {
    func selectLocationButtonTapped(sender: AnyObject) {
        delegate?.locationCalloutViewDidTap()
    }
}

extension Constants {
    struct LocationCalloutView {
        static let Identifier = "LocationCalloutView"
        static let Width = CGFloat(257)
        static let Padding = CGFloat(11)
        static let AddressLabelPadding = CGFloat(3)
        static let GettingAddress = NSLocalizedString("Getting address…", comment: "")
    }
}
