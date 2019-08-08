//
//  FELoadingViewController.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/8/6.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

class FELoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        MBProgressHUD.showAdded(to: self.view, animated: true)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
