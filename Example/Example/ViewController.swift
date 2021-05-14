//
//  ViewController.swift
//  Example
//
//  Created by Lee Burrows on 20/04/2021.
//

import UIKit
import SharkCardScan

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addStartButton()
        
        let scannerVC = SharkCardScanViewController(viewModel: CardScanViewModel(noPermissionAction: { [weak self] in
            
            self?.showNoPermissionAlert()
            
        }, successHandler: { (response) in
            print("Expiry 💣: \(response.expiry ?? "")")
            print("Card Number 💳: \(response.number)")
            print("Holder name 🕺: \(response.holder ?? "")")
        }))
        
        present(scannerVC, animated: true, completion: nil)

    }
    
    private func addStartButton() {
        let startCameraButton = UIButton(type: .custom, primaryAction: UIAction(title: "Start Card Scanner", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .mixed, handler: { _ in
            
            let scannerVC = SharkCardScanViewController(viewModel: CardScanViewModel(noPermissionAction: { [weak self] in
                
                self?.showNoPermissionAlert()
                
            }, successHandler: { (response) in
                print(response)
            }))
            
            self.present(scannerVC, animated: true, completion: nil)
        }))
        

        view.addSubview(startCameraButton)
        startCameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startCameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func showNoPermissionAlert() {
        
        showAlert(style: .alert, title: "Oopps, No access", message: "Check settings and ensure the app has permission to use the camera.", actions: [UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })])
    }
    
    func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.view.tintColor = UIColor.black
        actions.forEach {
            alertController.addAction($0)
        }
        if style == .actionSheet && actions.contains(where: { $0.style == .cancel }) == false {
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

