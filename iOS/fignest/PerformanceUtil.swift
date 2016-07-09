//
//  PerformanceUtil.swift
//  fignest
//
//  Created by Naim on 4/17/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import Foundation
import UIKit

struct PerformanceUtil {
    
    func measure(call: () -> Void) {
        let startTime = CACurrentMediaTime()
        call()
        let endTime = CACurrentMediaTime()
        
        print("Time - \(endTime - startTime)")
    }
    
    
}