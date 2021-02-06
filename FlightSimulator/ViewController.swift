//
//  ViewController.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 11.12.20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var cloudSwitch: UISwitch!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var highscoreButton: UIButton!
    @IBOutlet weak var difficultyText: UILabel!
    @IBOutlet weak var difficultySlider: UISlider!
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
    super.viewDidLoad()
        cloudSwitch.isOn = defaults.bool(forKey: Constants.CLOUD_OPTION)
        let difficulty = defaults.float(forKey: Constants.DIFFICULTY_OPTION)
        difficultySlider.value = difficulty
        setDifficultyLabel(difficulty: difficulty)
    }

    @IBAction func onDifficultyOptionChanged(_ sender: UISlider) {
        defaults.set(sender.value, forKey: Constants.DIFFICULTY_OPTION)
        setDifficultyLabel(difficulty: sender.value)
    }

    func setDifficultyLabel(difficulty: Float){
        difficultyText.font = difficultyText.font.withSize(CGFloat(difficulty * 10 + 12))
        difficultyText.textColor = UIColor(hue: (0.1094 + CGFloat(difficulty)) , saturation: 1, brightness: 0.74, alpha: 1.0)
    }
    
    @IBAction func onCloudOptionChanged(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: Constants.CLOUD_OPTION)
    }
}
