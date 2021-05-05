//
//  SharkCardScanViewController.swift
//  SharkCardScan
//
//  Created by Gymshark on 02/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import UIKit
import SharkUtils

public class SharkCardScanViewController: UIViewController {

    private var viewModel: CardScanViewModel
    private var styling: CardScanStyling
    
    private lazy var closeButton = UIButton().with {
        $0.setBackgroundImage(UIImage(named: "rounded close"), for: .normal)
        $0.accessibilityLabel = String(describing: SharkCardScanViewController.self) + "." + "CloseButton"
    }
    
    private let rootStackView = UIStackView().with { $0.axis = .vertical }
    private let cameraAreaView = UIView().withAspectRatio(3 / 4, priority: .defaultHigh)
    private let overlayView = LayerContentView(contentLayer: CAShapeLayer()).with {
        $0.contentLayer.fillRule = .evenOdd
    }
    private lazy var cardView = ScannedCardView(styling: styling)
    private lazy var instructionsLabel = UILabel().withFixed(width: 288).with {
        $0.text = viewModel.insturctionText
        $0.font = styling.instructionLabelStyling.font
        $0.textColor = styling.instructionLabelStyling.color
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    public init(viewModel: CardScanViewModel, styling: CardScanStyling = DefaultStyling()) {
        self.viewModel = viewModel
        self.styling = styling
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        closeButton.touchUpInside.action = viewModel.didTapClose
        viewModel.didDismiss = weakClosure(self) { (self) in
            self.dismiss(animated: true, completion: nil)
        }
        
        viewModel.update = weakClosure(self) { (self, state) in
            UIView.animate(withDuration: 0.2) {
                self.overlayView.contentLayer.fillColor = UIColor.black.withAlphaComponent(state.overlayMaskAlpha).cgColor
                self.cardView.backgroundColor = UIColor.black.withAlphaComponent(state.cuttoutBackgroundAlpha)
            }
            self.cardView.numberLabel.text = state.response?.number
            self.cardView.expiryLabel.text = state.response?.expiry
            self.cardView.holderLabel.text = state.response?.holder
        }
        
        view.withEdgePinnedContent {[
            rootStackView.withArrangedViews {[
                cameraAreaView.withEdgePinnedContent {[
                    viewModel.previewView,
                    overlayView.withVerticallyCenteredContent(safeArea: true, horizontalEdgePin: 20) {[
                        cardView
                    ]},
                    UIView().withEdgePinnedContent(.topRight(16, others: nil), safeArea: true) {[
                        closeButton
                    ]}
                ]},
                UIView().with { $0.backgroundColor = .white }.withCenteredContent {[
                    instructionsLabel
                ]}
            ]}
        ]}
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Give time for everthing to layout. Will maybe come back to but it will work fine
        DispatchQueue.main.async {
            let path = UIBezierPath(rect: self.overlayView.bounds)
            path.append(
                UIBezierPath(
                    roundedRect: self.overlayView.convert(self.cardView.bounds, from: self.cardView),
                    cornerRadius: self.cardView.layer.cornerRadius
                )
            )
            self.overlayView.contentLayer.path = path.cgPath
            
            self.viewModel.cardCuttoutInPreview(frame: self.viewModel.previewView.convert(self.cardView.bounds, from: self.cardView))
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startCamera()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopCamera()
    }
}
