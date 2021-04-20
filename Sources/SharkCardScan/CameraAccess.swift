//
//  CameraAccess.swift
//  Store
//
//  Created by Dominic Campbell on 10/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import Foundation
import AVFoundation

protocol CameraAccessProtocol {
    func request(_ compltion: @escaping (Bool) -> Void)
}

struct CameraAccess: CameraAccessProtocol {
    func request(_ compltion: @escaping (Bool) -> Void) {
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
