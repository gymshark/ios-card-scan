//
//  CardScanViewController.swift
//  Store
//
//  Created by Dominic Campbell on 02/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import UIKit
import SharkUtils

public class CardScanViewController: UIViewController {

    private var viewModel: CardScanViewModel
    
    private let closeButton = UIButton().with {
        $0.setBackgroundImage(UIImage(named: "rounded close"), for: .normal)
        $0.accessibilityLabel = "CLOSE"//.localized
    }
    private let rootStackView = UIStackView().with { $0.axis = .vertical }
    private let cameraAreaView = UIView().withAspectRatio(3 / 4, priority: .defaultHigh)
    private let overlayView = LayerContentView(contentLayer: CAShapeLayer()).with {
        $0.contentLayer.fillRule = .evenOdd
    }
    private let cardView = ScannedCardView()
    private let instructionsLabel = UILabel().withFixed(width: 288).with {
        $0.text = ""//.localized
        //$0.font = UIFont(style: .bodyBold, size: .heading(.h3))
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    public init(viewModel: CardScanViewModel) {
        self.viewModel = viewModel
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
    
    func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.view.tintColor = UIColor.black
        actions.forEach {
            alertController.addAction($0)
        }
        if style == .actionSheet && actions.contains(where: { $0.style == .cancel }) == false {
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            //localise me
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

private let cardAspectRatio: CGFloat = 86 / 54

private class ScannedCardView: UIView {
    
    private let rescaledAreaView = UIView().withFixed(width: 328).withAspectRatio(cardAspectRatio)
    private let rootStackView = UIStackView().with {
        $0.axis = .vertical
        $0.distribution = .fillEqually
    }
    private let detailsStackView = UIStackView().with {
        $0.axis = .vertical
        $0.spacing = 10
    }
    let numberLabel = UILabel().withFixed(height: 28).with {
        $0.textColor = .white
        //$0.font = UIFont(name: FontStyle.body.value, size: 28)
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
    }
    private let expiryStackView = UIStackView().with {
        $0.distribution = .fillEqually
    }
    let expiryLabel = UILabel().withFixed(height: 16).with {
        $0.textColor = .white
        //$0.font = UIFont(style: .body, size: .heading(.h4))
        //$0.font = UIFont(name: FontStyle.body.value, size: 16)
        $0.textAlignment = .right
    }
    private let holderStackView = UIStackView()
    let holderLabel = UILabel().withFixed(height: 16).with {
        $0.textColor = .white
        //$0.font = UIFont(name: FontStyle.body.value, size: 16)
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
    }
    
    init() {
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
