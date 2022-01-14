//
//  CountDown.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2019.
//

import Foundation

class CountDown {
    private var timer: Timer?

    func start(seconds: Int, fireBlock: @escaping (Int) -> Void, endBlock: @escaping () -> Void) {
        guard let finishTime = Date().add(seconds, units: .second) else { return }
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let pendingSeconds = Int(finishTime.timeIntervalSince(Date()))
            if pendingSeconds <= 0 {
                self.stop()
                endBlock()
            } else {
                fireBlock(pendingSeconds)
            }
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }

    func stop() {
        timer?.invalidate()
    }
}
