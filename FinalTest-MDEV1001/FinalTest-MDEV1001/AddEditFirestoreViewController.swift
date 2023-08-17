
//
//  AddEditFirestoreViewController.swift
//  FinalTest-MDEV1001
//
//  Created by Upasna Khatiwala on 2023-08-17.
//

import UIKit
import Firebase

class AddEditFirestoreViewController: UIViewController {

    // UI References
    @IBOutlet weak var AddEditTitleLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    
    // Movie Fields
    @IBOutlet weak var documentIDTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var castTextField: UITextField!
    @IBOutlet weak var genresTextField: UITextField!
    @IBOutlet weak var composersTextField: UITextField!
    @IBOutlet weak var creatorsTextField: UITextField!
    @IBOutlet weak var imageURLTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var episodesTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var seasonsTextField: UITextField!
    @IBOutlet weak var originalReleaseTextField: UITextField!
    @IBOutlet weak var networkTextField: UITextField!
    
    var show: Show?
    var showViewController: FirestoreCRUDViewController?
    var showUpdateCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let show = show {
            // Editing existing movie
            documentIDTextField.text = "\(show.documentID)"
            titleTextField.text = "\(show.title)"
            genresTextField.text = show.genres.joined(separator: ", ")
            composersTextField.text = show.composers.joined(separator: ", ")
            creatorsTextField.text = show.creators.joined(separator: ", ")
            castTextField.text = show.cast.joined(separator: ", ")
            episodesTextField.text = "\(show.episodes)"
            languageTextField.text = "\(show.language)"
            descriptionTextView.text = "\(show.description)"
            seasonsTextField.text = "\(show.seasons)"
            networkTextField.text = "\(show.network)"
            imageURLTextField.text = "\(show.imageURL)"
            originalReleaseTextField.text = "\(show.originalRelease)"
            AddEditTitleLabel.text = "Edit Show"
            UpdateButton.setTitle("Update", for: .normal)
        } else {
            AddEditTitleLabel.text = "Add Show"
            UpdateButton.setTitle("Add", for: .normal)
        }
    }
    
    @IBAction func CancelButton_Pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func UpdateButton_Pressed(_ sender: UIButton) {
        guard
              let title = titleTextField.text,
              let cast = castTextField.text,
              let genres = genresTextField.text,
              let composers = composersTextField.text,
              let creators = creatorsTextField.text,
              let episodes = episodesTextField.text,
              let language = languageTextField.text,
              let description = descriptionTextView.text,
              let seasons = seasonsTextField.text,
              let network = networkTextField.text,
              let imageURL = imageURLTextField.text,
              let originalRelease = originalReleaseTextField.text
        else {
            print("Invalid data")
            return
        }

        let db = Firestore.firestore()

        if let show = show {
            // Update existing movie
            guard let documentID = show.documentID else {
                print("Document ID not available.")
                return
            }
            
            let episodes = Int(episodes) ?? 0
                    let seasons = Int(seasons) ?? 0

            let showRef = db.collection("tvshows").document(documentID)
            showRef.updateData([
                "title": title,
                "cast": cast.components(separatedBy: ", "),
                "genres": genres.components(separatedBy: ", "),
                "composers": composers.components(separatedBy: ", "),
                "creators": creators.components(separatedBy: ", "),
                "episodes": episodes,
                "language": language,
                "seasons": seasons,
                "description": description,
                "network": network,
                "imageURL": imageURL,
                "originalRelease": originalRelease
            ]) { [weak self] error in
                if let error = error {
                    print("Error updating show: \(error)")
                } else {
                    print("Show updated successfully.")
                    self?.dismiss(animated: true) {
                        self?.showUpdateCallback?()
                    }
                }
            }
        } else {
            
            let episodes = Int(episodes) ?? 0
                    let seasons = Int(seasons) ?? 0
            // Add new movie
            let newShow     = [
                "title": title,
                "cast": cast.components(separatedBy: ", "),
                "genres": genres.components(separatedBy: ", "),
                "composers": composers.components(separatedBy: ", "),
                "creators": creators.components(separatedBy: ", "),
                "episodes": episodes,
                "language": language,
                "seasons": seasons,
                "description": description,
                "network": network,
                "imageURL": imageURL,
                "originalRelease": originalRelease
            ] as [String : Any]

            var ref: DocumentReference? = nil
            ref = db.collection("tvshows").addDocument(data: newShow) { [weak self] error in
                if let error = error {
                    print("Error adding show: \(error)")
                } else {
                    print("Show added successfully.")
                    self?.dismiss(animated: true) {
                        self?.showUpdateCallback?()
                    }
                }
            }
        }
    }
}
