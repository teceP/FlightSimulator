//
//  ViewController.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 11.12.20.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var cloudSwitch: UISwitch!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var highscoreButton: UIButton!
    @IBOutlet weak var difficultyText: UILabel!
    @IBOutlet weak var difficultySlider: UISlider!
    @IBOutlet weak var musicPickerView: UIPickerView!
    
    @IBOutlet weak var musicLabel: UILabel!
    let defaults = UserDefaults.standard
    var difficultyValue : Float = 0.5
    
    let pickerViewData = [Constants.MUSIC_FUNNY, Constants.MUSIC_HIGHWAY, Constants.MUSIC_SYNTH]

    override func viewDidLoad() {
    super.viewDidLoad()
        cloudSwitch.isOn = defaults.bool(forKey: Constants.CLOUD_OPTION)
        difficultyValue = defaults.float(forKey: Constants.DIFFICULTY_OPTION)
        difficultySlider.value = difficultyValue
        setDifficultyLabel(difficulty: difficultyValue)
        musicPickerView.delegate = self
        musicPickerView.dataSource = self
        styleButton(button: playButton)
        styleButton(button: highscoreButton)
    }
    
    func styleButton(button: UIButton){
        button.backgroundColor = UIColor(red: 171/255, green: 178/255, blue: 186/255, alpha: 1.0)
        // Shadow Color and Radius
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0.0
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 4.0
    }
    
    /*
     Stores the difficulty level right before the screen disappears
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaults.set(difficultyValue, forKey: Constants.DIFFICULTY_OPTION)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /*
     Controlls the difficulty label
     Does not store the difficulty value, according to avoid unneccesary massive
     writing into user defaults. Difficulty level will be stored when view dissappears.
     */
    @IBAction func onDifficultyOptionChanged(_ sender: UISlider) {
        setDifficultyLabel(difficulty: sender.value)
    }

    /*
     Sets the difficulty label-font size and color
     */
    func setDifficultyLabel(difficulty: Float){
        difficultyText.font = difficultyText.font.withSize(CGFloat(difficulty * 10 + 12))
        difficultyText.textColor = UIColor(hue: (0.1094 + CGFloat(difficulty)) , saturation: 1, brightness: 0.74, alpha: 1.0)
    }
    
    /*
     Stores the cloud/ghost option
     */
    @IBAction func onCloudOptionChanged(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: Constants.CLOUD_OPTION)
    }
    
    /*
     Number of Picker View Components
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*
     All rows count
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewData.count
    }
    
    /*
     Returns String of row from PickerViewData and stores the current selected.
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        defaults.set(pickerViewData[musicPickerView.selectedRow(inComponent: 0)], forKey: Constants.MUSIC_OPTION)
        return pickerViewData[row]
     }
}
