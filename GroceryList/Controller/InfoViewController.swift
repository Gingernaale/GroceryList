//
//  InfoViewController.swift
//  GroceryList
//
//  Created by Irunya =} on 06/08/2021.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var infoLabelTxt: UILabel!
    
    var infoLabel : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !infoLabel.isEmpty {
            infoLabelTxt.text = infoLabel
        }
    }
}
