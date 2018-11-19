//
//  ViewController.swift
//  Weather
//
//  Created by gaurav bagal on 11/19/18.
//  Copyright © 2018 gaurav bagal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var citySearch: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let session = URLSession.shared
        let cityUrl = URL(string: "https://www.ipapi.co/city")!
        var city: String?
        let _ = session.dataTask(with: cityUrl) { (data, response, error) in
            guard let data = data else {
                return
            }
            city = String(describing: data)
            return
        }
        if let city = city {
            cityLabel.text = city
        }
        
    }
    
    
    

}

