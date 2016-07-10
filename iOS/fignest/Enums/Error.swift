//
//  Error.swift
//  fignest
//
//  Created by Naim on 4/28/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import Foundation

enum ImageError: ErrorType {
    case BadUrlString(String)
    case InvalidUrl(String)
}
