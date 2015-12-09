//
//  Errors.swift
//  PinBike
//
//  Created by Le Tai on 10/16/15.
//  Copyright © 2015 Le Van Tai. All rights reserved.
//

import UIKit
import Utils

enum APIError: Int, ErrorType, CustomStringConvertible {
    case Unspecified = 7000
    case NoBodyFound = 7001
    case Cached = 7002
    case NoReceivers = 7003
    case ChattingRealtime = 7004
    case ChattingServer = 7005
    case Location = 7006
    
    case Unauthorized = 401
    case Forbidden = 403
    case PageNotFound = 404
    case TimeOut = 408
    case InternalServer = 500
    case Network = -1009
    
    var description: String {
        switch self {
        case .NoBodyFound:
            return NSLocalizedString("No content found", comment: "")
        case .Unspecified:
            return NSLocalizedString("An unspecified error occurred", comment: "")
        case .Cached:
            return NSLocalizedString("Can not access cache", comment: "")
        case .PageNotFound:
            return NSLocalizedString("Page Not Found", comment: "")
        case .Unauthorized:
            return NSLocalizedString("Authorization Required", comment: "")
        case .Forbidden:
            return NSLocalizedString("Forbidden", comment: "")
        case .TimeOut:
            return NSLocalizedString("Time Out", comment: "")
        case .InternalServer:
            return NSLocalizedString("Internal Server Error", comment: "")
        case .Network:
            return NSLocalizedString("Lost Internet Connection", comment: "")
        case .NoReceivers:
            return NSLocalizedString("No Receivers", comment: "")
        case .ChattingServer:
            return NSLocalizedString("Chatting Server Error", comment: "")
        case .ChattingRealtime:
            return NSLocalizedString("Your friend can not receive messages instantly", comment: "")
        case .Location:
            return NSLocalizedString("Could not get address, try again!", comment: "")
        }
    }
    
    func foundationError() -> NSError {
        return NSError(domain: Constants.Error.APIErrorDomain, code: rawValue, userInfo: [
            NSLocalizedDescriptionKey: description
            ])
    }
}

extension Constants {
    struct Error {
        static let APIErrorDomain = "com.PinBike.Error.API"
    }
}
