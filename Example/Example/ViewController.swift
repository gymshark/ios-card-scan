//
//  ViewController.swift
//  Example
//
//  Created by Lee Burrows on 20/04/2021.
//

import UIKit
import SharkCardScan

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scannerVC = CardScanViewController(viewModel: CardScanViewModel(noPermissionAction: { [weak self] in
            
            self?.showNoPermissionAlert()
            // no permission for camera
        }, successHandler: { (response) in
            
            print(response)
        }))
        
        present(scannerVC, animated: true, completion: nil)
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

