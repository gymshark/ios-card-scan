//
//  CameraAccess.swift
//  SharkCardScan
//
//  Created by Gymshark on 10/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import Foundation
import AVFoundation

public protocol CameraAccessProtocol {
    func request(_ compltion: @escaping (Bool) -> Void)
}

public struct CameraAccess: CameraAccessProtocol {
    public init () { }
    public func request(_ compltion: @escaping (Bool) -> Void) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            compltion(true)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { success in
                DispatchQueue.main.async {
                    compltion(success)
                }
            }
        }
    }
}
