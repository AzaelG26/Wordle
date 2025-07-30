//
//  RecordsViewController.swift
//  Wordle
//
//  Created by Azael García Candela on 30/07/25.
//

import UIKit

class RecordsViewController: UIViewController {

    @IBOutlet weak var contenedorRecordsView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = UIColor(red: 112/255, green: 157/255, blue: 98/255, alpha: 1.0)

        // Prueba de scroll
        contenedorRecordsView.translatesAutoresizingMaskIntoConstraints = false
        contenedorRecordsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        var vistaAnterior: UIView?

        for i in 0..<10 {
            let pruebaView = UIView()
            pruebaView.backgroundColor = .systemGreen
            pruebaView.translatesAutoresizingMaskIntoConstraints = false
            contenedorRecordsView.addSubview(pruebaView)

            NSLayoutConstraint.activate([
                pruebaView.leadingAnchor.constraint(equalTo: contenedorRecordsView.leadingAnchor, constant: 10),
                pruebaView.trailingAnchor.constraint(equalTo: contenedorRecordsView.trailingAnchor, constant: -10),
                pruebaView.heightAnchor.constraint(equalToConstant: 60)
            ])

            if i == 0 {
                pruebaView.topAnchor.constraint(equalTo: contenedorRecordsView.topAnchor, constant: 16).isActive = true
            } else if let anterior = vistaAnterior {
                pruebaView.topAnchor.constraint(equalTo: anterior.bottomAnchor, constant: 10).isActive = true
            }

            if i == 9 {
                pruebaView.bottomAnchor.constraint(equalTo: contenedorRecordsView.bottomAnchor, constant: -16).isActive = true
            }

            vistaAnterior = pruebaView
        }
    }
    



}
