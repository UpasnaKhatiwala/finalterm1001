//
//  FirestoreCRUDViewController.swift
//  FinalTest-MDEV1001
//
//  Created by Upasna Khatiwala on 2023-08-17.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreCRUDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var shows: [Show] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchShowsFromFirestore()
    }

    func fetchShowsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("tvshows").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            var fetchedShows: [Show] = []

            for document in snapshot!.documents {
                let data = document.data()

                do {
                    var show = try Firestore.Decoder().decode(Show.self, from: data)
                    show.documentID = document.documentID // Set the documentID
                    fetchedShows.append(show)
                } catch {
                    print("Error decoding show data: \(error)")
                }
            }

            DispatchQueue.main.async {
                self.shows = fetchedShows
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! ShowTableViewCell

        let show = shows[indexPath.row]

        cell.TitleLabel?.text = show.title
        cell.originalRelaeseLabel?.text = show.originalRelease
        cell.episodesLabel?.text = "\(show.episodes)"

        let episodes = show.episodes

        if episodes > 50 {
            cell.episodesLabel.backgroundColor = UIColor.green
            cell.episodesLabel.textColor = UIColor.black
        } else if episodes > 30 {
            cell.episodesLabel.backgroundColor = UIColor.yellow
            cell.episodesLabel.textColor = UIColor.black
        } else {
            cell.episodesLabel.backgroundColor = UIColor.red
            cell.episodesLabel.textColor = UIColor.white
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AddEditSegue", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let show = shows[indexPath.row]
            showDeleteConfirmationAlert(for: show) { confirmed in
                if confirmed {
                    self.deleteShow(at: indexPath)
                }
            }
        }
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "AddEditSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddEditSegue" {
            if let addEditVC = segue.destination as? AddEditFirestoreViewController {
                addEditVC.showViewController = self
                if let indexPath = sender as? IndexPath {
                    let show = shows[indexPath.row]
                    addEditVC.show = show
                } else {
                    addEditVC.show = nil
                }

                addEditVC.showUpdateCallback = { [weak self] in
                    self?.fetchShowsFromFirestore()
                }
            }
        }
    }

    func showDeleteConfirmationAlert(for show: Show, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Delete Show", message: "Are you sure you want to delete this show?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            completion(true)
        })

        present(alert, animated: true, completion: nil)
    }

    func deleteShow(at indexPath: IndexPath) {
        let show = shows[indexPath.row]

        guard let documentID = show.documentID else {
            print("Invalid document ID")
            return
        }

        let db = Firestore.firestore()
        db.collection("tvshows").document(documentID).delete { [weak self] error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                DispatchQueue.main.async {
                    print("show deleted successfully.")
                    self?.shows.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
