//
//  ViewController.swift
//  Wordle
//
//  Created by Azael García Candela on 10/07/25.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var soundButton: UIButton!
    
    var sonidoActivo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        alternarIconoSonido()
    }
    
    @IBAction func cambiarSonido(_ sender: Any) {
        sonidoActivo.toggle()
        alternarIconoSonido()
        if sonidoActivo {
            print("Sonido activado")
        } else {
            print("Sonido desactivado")
        }
    }
    
    func alternarIconoSonido() {
        let nombreImagen = sonidoActivo ? "speaker.fill" : "speaker.slash.fill"
            soundButton.setImage(UIImage(systemName: nombreImagen), for: .normal)
    }


}

