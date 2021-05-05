//
//  CardScanner.swift
//  SharkCardScan
//
//  Created by Gymshark on 04/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import Foundation
import Vision
import SharkUtils

public struct CardScannerResponse: Equatable {
    public init(number: String, expiry: String?, holder: String?) {
        self.number = number
        self.expiry = expiry
        self.holder = holder
    }
    
    public let number: String
    public let expiry: String?
    public let holder: String?
}

public protocol CardScannerProtocol: AnyObject {
    var output: (CardScannerResponse?) -> Void { get set }
    var regionOfInterest: CGRect { get set }
    func read(buffer: CVPixelBuffer, orientation: CGImagePropertyOrientation)
    func reset()
}

private let regionOfInterestDefault = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))

public final class CardScanner: CardScannerProtocol {
    
    @ThreadSafe public var output: (CardScannerResponse?) -> Void
    @ThreadSafe public var regionOfInterest: CGRect
    private let nowInMonthsSince2000: Int
    private let writeSafe = WriteSafe()
    private var numberDigitsOnly: Item<String?> = Item(value: nil)
    private var number: Item<String?> = Item(value: nil)
    private var expiryInMonthsSince2000: Item<Int?> = Item(value: nil)
    private var holder: Item<String?> = Item(value: nil)
    private var requestsInFlight: Int = 0
    private let queue = DispatchQueue(label: "com.gymshark.cardscan.CardScanner", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    public init(now: Date = Date()) {
        self._regionOfInterest = ThreadSafe(wrappedValue: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)), writeSafe: self.writeSafe)
        self.nowInMonthsSince2000 = now.monthsSince2000
        self._output = ThreadSafe(wrappedValue: { _ in }, writeSafe: self.writeSafe)
    }
    
    public func read(buffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
        writeSafe.perform {
            guard requestsInFlight <= 1 else {
                return
            }
            requestsInFlight += 1
            
            let request = VNRecognizeTextRequest(completionHandler: weakClosure(self) { (self, request, error) in
                self.writeSafe.perform {
                    self.process(request: request, error: error)
                    self.requestsInFlight -= 1
                }
            })
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true // false is meant to be better for numbers but overall I find it better with
            request.customWords = (0...9).map { "\($0)" } + ["MISS", "MRS", "MS", "MR", "DR", "PROF"] // Not sure this helps
            request.minimumTextHeight = _regionOfInterest.unsafeValue == regionOfInterestDefault ? 0 : 0.1 // Signicantly reduces CPU load with some cards
            request.recognitionLanguages = ["en_US"]
            if #available(iOS 14.0, *) {
                // Avoid new iOS versions moving to a newer version with differnet behaviours
                request.revision = VNRecognizeTextRequestRevision2
            }
            
            let handler = VNImageRequestHandler(
                ciImage: Self.preprocess(buffer: buffer, regionOfInterest0to1: _regionOfInterest.unsafeValue),
                orientation: orientation
            )
            queue.async {
                do {
                    try handler.perform([request])
                } catch {
                    print("\(error)")
                }
            }
           
        }
    }
    
    public func reset() {
        writeSafe.perform {
            number.reset()
            numberDigitsOnly.reset()
            expiryInMonthsSince2000.reset()
            holder.reset()
            _output.unsafeValue(nil)
        }
    }
    
    private func process(request: VNRequest, error: Error?) {
        if let error = error {
            print("\(error)")
            return
        }
        (request.results as? [VNRecognizedTextObservation] ?? []).forEach {
            let bounds = $0.boundingBox
            for observation in $0.topCandidates(3) {
                if let value = Self.extractNumber(observation.string, current: number.currentMatch.value ?? "") {
                    let unformatted = String(value.filter { $0.isWholeNumber })
                    if unformatted != numberDigitsOnly.currentMatch.value {
                        number.reset()
                    }
                    numberDigitsOnly.process(newValue: unformatted, observation: observation, bounds: bounds)
                    number.process(newValue: value, observation: observation, bounds: bounds)
                    return
                }
                if let value = Self.extractExpiryInMonthsSince2000(observation.string, now: nowInMonthsSince2000) {
                    expiryInMonthsSince2000.process(newValue: value, observation: observation, bounds: bounds)
                    return
                }
                /*
                 After extractExpiry: to allow "EXP 02/25" etc
                 Before extractHolder: to reduce holder false possitives
                 */
                if Self.shouldIgnore(observation.string) {
                    return
                }
                if let value = Self.extractHolder(observation.string,
                                                  current: holder.currentMatch.value ?? "",
                                                  bounds: bounds,
                                                  numberBounds: numberDigitsOnly.bounds,
                                                  expiryBounds: expiryInMonthsSince2000.bounds) {
                    holder.process(newValue: value, observation: observation, bounds: bounds)
                    return
                }
            }
        }
        guard numberDigitsOnly.currentMatch.hits > 1 else {
            return
        }
        _output.unsafeValue(
            CardScannerResponse(
                number: number.currentMatch.value ?? "",
                expiry: expiryInMonthsSince2000.currentMatch.value.flatMap { type(of: self).format(monthsSince2000: $0) },
                holder: holder.highestRunMatch.hits > 1 ? holder.highestRunMatch.value : nil
            )
        )
    }
}
