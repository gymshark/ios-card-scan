//
//  CardScanViewModel.swift
//  SharkCardScan
//
//  Created by Gymshark on 02/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import Foundation
import Vision
import VisionKit
import SharkUtils
import AudioToolbox

struct CardScanViewModelState: Equatable {
    var response: CardScannerResponse?
    var overlayMaskAlpha: CGFloat {
        response == nil ? 0.5 : 0.9
    }
    var cuttoutBackgroundAlpha: CGFloat {
        response == nil ? 0 : 0.5
    }
    var selectEnabled: Bool {
        response != nil
    }
}

public class CardScanViewModel {
    private let cameraAccess: CameraAccessProtocol
    private let cameraStream: PixelBufferStream
    private let cardReader: CardScannerProtocol
    private let noPermissionAction: () -> Void
    var didDismiss: (() -> Void)?
    private let successHandler: (CardScannerResponse) -> Void
    private var timerActive = false
    
    public var closeButtonTitle: String = "Close"
    public var insturctionText: String = "Scan a card"
    
    var previewView: UIView {
        cameraStream.previewView
    }
    var state = CardScanViewModelState() {
        didSet {
            update(state)
        }
    }
    var update: (CardScanViewModelState) -> Void = { _ in } {
        didSet {
            update(state)
        }
    }
    
    public init(cameraAccess: CameraAccessProtocol = CameraAccess(),
         cameraStream: PixelBufferStream = CameraPixelBufferStream(),
         cardReader: CardScannerProtocol = CardScanner(),
         noPermissionAction: @escaping () -> Void,
         successHandler: @escaping (CardScannerResponse) -> Void) {
        self.cameraAccess = cameraAccess
        self.cameraStream = cameraStream
        self.cardReader = cardReader
        self.noPermissionAction = noPermissionAction
        self.successHandler = successHandler
        cameraStream.output = cardReader.read(buffer:orientation:)
        cardReader.output = weakClosure(self, on: .main) {
            $0.state.response = $1
            guard $0.timerActive == false else { return }
            $0.timerActive = true
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            DispatchQueue.main.asyncWeakClosure($0, afterDeadline: .now() + .seconds(1)) {
                $0.cameraStream.running = false
            }
            DispatchQueue.main.asyncWeakClosure($0, afterDeadline: .now() + .seconds(2)) {
                guard let response = $0.state.response else { return }
                $0.successHandler(response)
                // Odd bug will cause parentVC showing as half dismissed, well inspect when I have some time
                DispatchQueue.main.asyncWeakClosure($0) { _ in
                   // $0.viewServices?.dismiss()
                    self.didDismiss?()
                    
                }
            }
        }
    }
    
    func didTapClose() {
        didDismiss?()
    }
    
    func startCamera() {
        cameraAccess.request(weakClosure(self) { (self, success) in
            if success {
                self.cameraStream.running = true
            } else {
                self.noPermissionAction()
            }
        })
    }
    
    func stopCamera() {
        cameraStream.running = false
    }
    
    func cardCuttoutInPreview(frame: CGRect) {
        cardReader.regionOfInterest = cameraStream.cameraRegion(forPreviewRegion: frame)
    }
}
