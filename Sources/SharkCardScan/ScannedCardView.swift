//
//  File.swift
//  
//
//  Created by Lee Burrows on 03/05/2021.
//

import UIKit
private let cardAspectRatio: CGFloat = 86 / 54
internal final class ScannedCardView: UIView {
    
    private let rescaledAreaView = UIView().withFixed(width: 328).withAspectRatio(cardAspectRatio)
    private let rootStackView = UIStackView().with {
        $0.axis = .vertical
        $0.distribution = .fillEqually
    }
    private let detailsStackView = UIStackView().with {
        $0.axis = .vertical
        $0.spacing = 10
    }
    
    lazy var numberLabel = UILabel().withFixed(height: 28).with {
        $0.textColor = .white
        $0.font = styling.cardNumberLabelStyling.font
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
    }
    private let expiryStackView = UIStackView().with {
        $0.distribution = .fillEqually
    }
    
    lazy var expiryLabel = UILabel().withFixed(height: 16).with {
        $0.textColor = .white
        $0.font = styling.expiryLabelStyling.font
        $0.textAlignment = .right
    }
    private let holderStackView = UIStackView()
    
    lazy var holderLabel = UILabel().withFixed(height: 16).with {
        $0.textColor = .white
        $0.font = styling.holderLabelStyling.font
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private var styling: CardScanStyling
    
    init(styling: CardScanStyling) {
        self.styling = styling
        super.init(frame: .zero)
        
        layer.cornerRadius = 10
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
        withAspectRatio(cardAspectRatio)
        
        withCenteredContent {[
            rescaledAreaView.withEdgePinnedContent {[
                UIView().withEdgePinnedContent(.all(16)) {[
                    rootStackView.withArrangedViews {[
                        .spacer(),
                        detailsStackView.withArrangedViews {[
                            numberLabel,
                            expiryStackView.withArrangedViews {[
                                expiryLabel,
                                .spacer()
                            ]},
                            holderLabel
                        ]}
                    ]}
                ]}
            ]}
        ]}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            /*
             The card details layout is meant to represent a card's layout so should be the same regardless of device size.
             
             So simplify this the card's layout has been done at a fixed size and rescaled
             */
            let scale = self.bounds.width / self.rescaledAreaView.bounds.width
            self.rescaledAreaView.transform = .init(scaleX: scale, y: scale)
        }
    }
}
