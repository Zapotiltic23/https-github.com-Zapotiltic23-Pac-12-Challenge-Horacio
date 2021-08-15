//
//  File.swift
//  Pac-12_Challenge
//
//  Created by Horacio Alexandro Sanchez on 8/14/21.
//

import UIKit


extension UIColor {
    
    static var pac12MainBlue = UIColor(red: 0/255, green: 75/255, blue: 145/255, alpha: 1)
    static var pac12NavyBlue = UIColor(red: 4/255, green: 34/255, blue: 63/255, alpha: 1)
    
}

extension TimeInterval{
    
    func astimeIntervalMinSec() -> String {
      let minute = Int(self) / 60 % 60
      let second = Int(self) % 60
      return String(format: "%2i:%02i", minute, second)
    }
    
}
