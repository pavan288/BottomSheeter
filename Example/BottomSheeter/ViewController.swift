//
//  ViewController.swift
//  BottomSheeter
//
//  Created by pavan.powani@practo.com on 03/13/2020.
//  Copyright (c) 2020 pavan.powani@practo.com. All rights reserved.
//

import BottomSheeter
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func buttonTapped(_ sender: Any) {
        let content = UIViewController()
        content.view.backgroundColor = .red
        let controller = BottomSheetViewController.getController(with: content)

        self.present(controller, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

