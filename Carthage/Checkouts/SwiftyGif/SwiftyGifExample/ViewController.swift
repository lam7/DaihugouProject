//
//  ViewController.swift
//  SwiftyGifManager
//

import UIKit
import SwiftyGif

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let gifManager = SwiftyGifManager(memoryLimit:100)
    let images = ["single_frame_Zt2012",
                  "no_property_dictionary.gif",
                  "sample.jpg",
                  "1", "2", "3", "5", "4"
    ]

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailController = segue.destination as? DetailController {
            let indexPath = self.tableView.indexPathForSelectedRow
            detailController.gifName = images[indexPath!.row]
        }
    }

    // MARK: - TableView Datasource

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! Cell


        if let image = try? UIImage(imageName: images[indexPath.row]) {
            cell.gifImageView.setImage(image, manager: gifManager, loopCount: -1)
        } else {
            cell.gifImageView.clear()
        }

        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

}

