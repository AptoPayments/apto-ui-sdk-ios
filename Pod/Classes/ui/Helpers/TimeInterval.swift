//
//  TimeInterval.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 24/03/2019.
//

import Foundation

extension TimeInterval {
  func stringFromTimeInterval() -> String {
    let time = NSInteger(self)
    let seconds = time % 60
    let minutes = (time / 60) % 60
    return String(format: "%0.2d:%0.2d", minutes, seconds)
  }
}
