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
        view.backgroundColor = .red
    }
    
    func showNoPermissionAlert() {
        
        showAlert(style: .alert, title: "CARD_SCAN_NO_CAMERA_ACCESS_TITLE", message: "CARD_SCAN_NO_CAMERA_ACCESS_MESSAGE", actions: [UIAlertAction(title: "OK", style: .default, handler: { (_) in
            // go to settings
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
            //localise me
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

