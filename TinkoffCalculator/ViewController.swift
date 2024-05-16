//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Dmitrii Dorogov on 12.05.2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        print(buttonText)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

