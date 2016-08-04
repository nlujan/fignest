//
//  StyleManager.swift
//  fignest
//
//  Created by Naim on 4/1/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

struct StyleUtil {
    
    let primaryColor = UIColor(red: 0.549, green:0.133, blue:0.165, alpha: 1.0)
    let progressViewColors = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor()]
    
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}


