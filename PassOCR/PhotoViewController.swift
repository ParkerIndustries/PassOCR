//
//  PhotoViewController.swift
//  PassOCR
//
//  Created by Marcus Florentin on 08/11/2019.
//  Copyright © 2019 Marcus Florentin. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    // MARK: - Storyboard
    
//    @IBOutlet weak var photoView: UIView!
    
    @IBOutlet weak var actionLabel: UILabel!
    
    // MARK: - Photo View Controller
    /// Tous les utilisateurs scannés
    var users: [User] = []
    
    /// Utilisateur actuellement en train de reconnaître
    var currentUser: User? = nil
    // MARK: Recognition
    
    // TODO: Create User w/ name & surname
   
    // TODO: Create timer
    func createUser(name: String, surname: String) -> Void {
        let new = User(name: name, surname: surname)
        
         // TODO: Show users values
        
        // TODO: Create timer
        
//        actionLabel.isHidden = true
    }
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        actionLabel.text = "Bienvenue \(name)"
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
