//
//  LaunchViewController LaunchViewController LaunchViewController LaunchViewController.swift
//  Wordle
//
//  Created by Azael García Candela on 10/07/25.
//

import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var worldleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worldleImageView.alpha = 0
        worldleImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.worldleImageView.alpha = 1
            self.worldleImageView.transform = CGAffineTransform.identity
        }, completion: { _ in
            UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseIn, animations: {
                self.worldleImageView.alpha = 0
            }, completion: { _ in
                self.performSegue(withIdentifier: "sgToMenu", sender: nil)
            })
        })
    }
}


