//
//  TableViewController.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 13.12.20.
//

import UIKit

class TableViewController: UITableViewController {
    
    /*
     All Game Results
     */
    var gameResults = PostGameController.getGameResultArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gameResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameResultCell", for: indexPath)
        let title = cell.viewWithTag(1000) as! UILabel
        let info = cell.viewWithTag(1001) as! UILabel
        
        let gameResult = gameResults[indexPath.row]
        
        title.text = String(gameResult.distance) + " Meter"
        info.text = gameResult.description()
        
        colorFirstThree(cell: cell, row: indexPath.row)
        
        return cell
    }
    
    /*
     Colors the first three places in the table view
     */
    private func colorFirstThree(cell: UITableViewCell, row: Int){
        if row == 0 {
            cell.contentView.backgroundColor = UIColor(hue: 0.2667, saturation: 1, brightness: 0.89, alpha: 1.0)
        }
        
        if row == 1 {
            cell.contentView.backgroundColor = UIColor(hue: 0.2667, saturation: 1, brightness: 0.89, alpha: 0.5)
        }
        
        if row == 2 {
            cell.contentView.backgroundColor = UIColor(hue: 0.2667, saturation: 1, brightness: 0.89, alpha: 0.2)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
