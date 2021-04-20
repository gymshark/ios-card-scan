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
        
        let scannerVM = CardScanViewController(viewModel: CardScanViewModel(openSettingsAction: {
            // open settings
        }, noPermissionAction: {
            // no permission for camera
        }, successHandler: { (response) in
            print(response)
        }))
        
        present(scannerVM, animated: true, completion: nil)
        view.backgroundColor = .red
    }
}

