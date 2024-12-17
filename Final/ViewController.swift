//
//  ViewController.swift
//  Final
//
//  Created by Pallavi on 2024-12-13.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var addTripButton: UIButton!

        override func viewDidLoad() {
            super.viewDidLoad()
        }

        @IBAction func addTripButtonTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "toAddTripPage", sender: self)
        }
    
    @IBAction func myTripsButtonTapped(_ sender: UIButton) {
            // Trigger the segue with the identifier "toTripListPage"
            performSegue(withIdentifier: "myTripsPageTapped", sender: self)
        }


}

