//
//  CardScannerExtensions.swift
//  SharkCardScan
//
//  Created by Gymshark on 05/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import UIKit
import Vision
import SharkUtils

private let numberCheck: RegexHandle = #"""
^                   # start of string
(\d\s*){12,18}\d    # Basic for now 13 to 19 digits with possible whitespace inbetween digits
$                   # end of string
"""#

private let preferredNumberFormatCheck: RegexHandle = #"""
^                   # start of string
[4-6]\d{3}          # Basic for now 13 to 19 digits with possible whitespace inbetween digits
\s
(\d{4,}\s){1,}
\d{3,}
$                   # end of string
"""#

private let expiryCheck: RegexHandle = #"""
^                   # start of string
.*?                 # some possible stuff; handles the `\(startDate)-\(endDate)` format case
(\d{2})             # capture group for exactly 2 digits
\/                  # single /
(\d{2})             # capture group for exactly 2 digits
$                   # end of string
"""#

private let whitespaceCaptureGroupRun: RegexHandle = #"""
(\s{1,})               # capture group for 1 or more whitespace; NSRegularExpression.stringByReplacingMatches requires a capture group
"""#

private let holderCheck: RegexHandle = #"""
^                   # start of string
[A-Z']{1,24}
\.?
\s
[A-Z]
[A-Z'\s]{3,23}
\.?
$                   # end of string
"""#

private let preferredHolderPrefixCheck: RegexHandle = #"""
^                           # start of string
(MISS|MRS|MS|MR|DR|PROF)    # common title match
\.?                         # optional '.'
\s                          # single space
.*                          # other stuff
$                           # end of string
"""#

private let ignores = [
    "visa",
    "mastercard",
    "amex",
    "debit",
    "credit",
    "from",
    "end",
    "valid",
    "exp",
    "until",
    "account",
    "number",
    "sort",
    "code"
]

extension CardScanner {
    
    struct Match<T: Equatable>: Equatable {
        var value: T
        var hits: Int = 0
    }
    
    struct Item<T: Equatable>: Equatable {
        var confidence: Float = 0
        var currentMatch: Match<T>
        var highestRunMatch: Match<T>
        var bounds = CGRect.zero
        private let startingValue: T
        init(value: T) {
            self.startingValue = value
            self.currentMatch = .init(value: value)
            self.highestRunMatch = .init(value: value)
        }
        
        mutating func reset() {
            self = Item(value: startingValue)
        }
        
        mutating func process(newValue: T, observation: VNRecognizedText, bounds: CGRect) {
            guard observation.confidence >= 0.3, observation.confidence >= confidence else {
                self.bounds = currentMatch.value == newValue ? bounds : self.bounds
                return
            }
            currentMatch.hits = currentMatch.value != newValue ? 1 : currentMatch.hits + 1
            currentMatch.value = newValue
            if currentMatch.hits >= highestRunMatch.hits {
                highestRunMatch = currentMatch
            }
            confidence = observation.confidence
            self.bounds = bounds
        }
    }

    static func extractNumber(_ source: String, current: String) -> String? {
        // Strip consecutive whitespace but otherwise leave the formatting alone until a there is a formatter added to the UI
        let sourceHasPreferedFormat = preferredNumberFormatCheck.regex.matches(in: source).isEmpty == false
        let currentHasPreferedFormat = preferredNumberFormatCheck.regex.matches(in: current).isEmpty == false
        return numberCheck.regex.stringMatches(in: source).isEmpty == false
            && CardCheck.hasValidLuhnChecksum(source)
            && (sourceHasPreferedFormat == false && currentHasPreferedFormat) == false
            ? whitespaceCaptureGroupRun.regex.stringByReplacingMatches(in: source, options: .withoutAnchoringBounds, range: source.fullNSRange, withTemplate: " ")
            : nil
    }
    
    static func extractExpiryInMonthsSince2000(_ source: String, now: Int) -> Int? {
        let matches = expiryCheck.regex.stringMatches(in: source)
        guard matches.count == 3, let month = Int(matches[1]), let year = Int(matches[2]), 1 <= month && month <= 12  else {
            return nil
        }
        let result = month - 1 + 12 * year
        let fiveYears = 12 * 5
        return now <= result && result <= now + fiveYears  ? result : nil
    }
    
    static func extractHolder(_ source: String, current: String, bounds: CGRect, numberBounds: CGRect, expiryBounds: CGRect) -> String? {
        let sourceHasPreferedPrefix = preferredHolderPrefixCheck.regex.matches(in: source).isEmpty == false
        let currentHasPreferedPrefix = preferredHolderPrefixCheck.regex.matches(in: current).isEmpty == false
        guard
            bounds.maxY < numberBounds.minY,
            (sourceHasPreferedPrefix == false && currentHasPreferedPrefix) == false,
            (sourceHasPreferedPrefix && currentHasPreferedPrefix == false) || source.count + 3 >= current.count,
            holderCheck.regex.matches(in: source).isEmpty == false
        else {
            return nil
        }
        return source
    }
    
    static func shouldIgnore(_ source: String) -> Bool {
        let lowercase = source.lowercased().replacingOccurrences(of: " ", with: "")
        return ignores.first { lowercase.contains($0) } != nil
    }
    
    static func format(monthsSince2000: Int) -> String {
        String(format: "%02d/%02d", (monthsSince2000 % 12) + 1, monthsSince2000 / 12)
    }
    
    static func preprocess(buffer: CVPixelBuffer, regionOfInterest0to1: CGRect) -> CIImage {
        var cropArea = regionOfInterest0to1
        cropArea.size.height = 0.5 * cropArea.size.height // We only care about the bottom of the card
        
        let size = CVImageBufferGetDisplaySize(buffer)
        cropArea = cropArea.applying(CGAffineTransform(scaleX: size.width, y: size.height))
        
        return CIImage(cvPixelBuffer: buffer)
            .cropped(to: cropArea) // speed
//            .applyingFilter("CIPhotoEffectTonal") // accuracy; make black and white
//            .applyingFilter("CISharpenLuminance", parameters: ["inputSharpness": 16]) // accuracy
            .applyingFilter("CILanczosScaleTransform", parameters: ["inputScale": 432 / size.width, "inputAspectRatio": 1]) // speed
    }
}
