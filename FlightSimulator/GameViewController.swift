//
//  GameViewController.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 11.12.20.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    
    var cloudFabric: EnemyFabric = EnemyFabric()
    var airplane = Airplane()
    var gameModel: GameModel = GameModel()
    let postGameController: PostGameController = PostGameController()
    var screenWidth = UIScreen.main.fixedCoordinateSpace.bounds.width
    var screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height
    
    @IBOutlet weak var musicOnButton: UIButton!
    @IBOutlet weak var musicOffButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var diffi = UserDefaults.standard.float(forKey: Constants.DIFFICULTY_OPTION) * 400
        if diffi < 1 {
            diffi = 1
        }
        gameModel.maxRandom = gameModel.maxRandom - Int(diffi)
        print("Max random: ", gameModel.maxRandom)
        gameModel.cloudSpeed = gameModel.cloudSpeed + Double(diffi/150)
        gameModel.difficulty = Int(diffi)
        gameModel.fileManagerUrls = gameModel.fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        gameModel.cloudSpawnY = Float(screenHeight - 20.0)
        self.view.addSubview(airplane.image)
        timeLabel.text = String(airplane.maxTime)
        speedLabel.text = String(airplane.speed)
        distanceLabel.text = String(airplane.distance)
        difficultyLabel.text = String(Double(diffi).roundToDecimal(2))
        gameModel.distanceTimestampPerSpeed.append(DistanceMeasurement(speed: airplane.speed))
        
        do {
            let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3")
            gameModel.player = try AVAudioPlayer(contentsOf: url!)
            gameModel.player.play()
           } catch let error as NSError {
               print("Failed to init audio player: \(error)")
           }
        
        gameLoop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameModel.doLoop = false
        gameModel.player.stop()
        print("Game loop stopped.")
    }
    
    @IBAction func onMusicOnButtonClicked(_ sender: UIButton) {
        showToast(message:  "Music on.")
        musicOnButton.isHidden = true
        musicOffButton.isHidden = false
        gameModel.player.play()
    }
    
    @IBAction func onMusicOffButtonClicked(_ sender: UIButton) {
        showToast(message:  "Music off.")
        musicOnButton.isHidden = false
        musicOffButton.isHidden = true
        gameModel.player.pause()
    }
    
    @IBAction func moveAirplane(_ sender: UISlider) {
        airplane.image.center.x = ((CGFloat(screenWidth/2)) + (CGFloat(sender.value) * 300)) - 150
    }
    
    func didCollide() -> Bool {
        for index in gameModel.clouds.indices {
            if(gameModel.clouds[index].collided == false && gameModel.clouds[index].image.frame.intersects(airplane.image.frame)){
                gameModel.clouds[index].collided = true
                gameModel.clouds[index].image.backgroundColor = UIColor.red
                print("Cloud is in same frame as airplane")
                return true
            }
        }
        return false
    }
    
    func updateValues(){
        gameModel.loops += 1
    
        timeLabel.text = String(Double(airplane.maxTime - gameModel.runningTime).roundToDecimal(2))
        speedLabel.text = String(airplane.speed.roundToDecimal(2))
        
        gameModel.distanceTimestampPerSpeed[gameModel.distanceTimestampPerSpeed.count-1].distanceInMeter = computeDistanceForCurrentSpeed()
        distanceLabel.text = String((airplane.distance + gameModel.distanceTimestampPerSpeed[gameModel.distanceTimestampPerSpeed.count-1].distanceInMeter).roundToDecimal(2))
    }
    
    func computeDistanceForCurrentSpeed() -> Double{
        let temp = gameModel.distanceTimestampPerSpeed[gameModel.distanceTimestampPerSpeed.count-1]
        let meterPerSeconds = airplane.speed / 3.6
        let secondsWithThisSpeed = temp.createdAt.distance(to: Date())
        return meterPerSeconds * secondsWithThisSpeed
    }
    
    /**
            true = game is over
            false = game is not over
     */
    func checkGameStatus() -> Bool{
        if gameModel.runningTime >= self.airplane.maxTime {
            return true
        }else if airplane.speed <= airplane.demolitionSpeed {
            return true
        }
        return false
    }

    
    func createCloud(){
        let distanceToLatest = gameModel.clouds.last?.date.distance(to: Date())
        if gameModel.clouds.count == 0 || gameModel.clouds.count < 5 && distanceToLatest! > gameModel.minSpawnDistance {
            
            let random = Int.random(in: 0..<gameModel.maxRandom)
            if random < gameModel.difficulty{
                let c = self.cloudFabric.createCloud()
                self.view.addSubview(c.image)
                gameModel.clouds.append(c)
                print("Cloud created. ", gameModel.clouds.count, " are active.")
            }
        }
    }
    
    func moveCloud(cloud: Cloud){
        cloud.image.frame.origin.y += CGFloat(gameModel.cloudSpeed)
        cloud.image.frame.origin.x += CGFloat(gameModel.wind)
    }
    
    func removeCloud(){
        for (i, cloud) in gameModel.clouds.enumerated().reversed() {
            moveCloud(cloud: cloud)
            if cloud.image.frame.origin.y > CGFloat(screenHeight){
                gameModel.clouds.remove(at: i)
                print("Cloud delete")
            }
        }
    }
    
    func computeWind(){
        if(gameModel.wind < 5 && gameModel.difficulty > 200){
            gameModel.wind += Double((gameModel.difficulty / 400))
        }
    }
    
    func stopClouds(){
        gameModel.clouds.forEach{cloud in
            cloud.image.layer.removeAllAnimations()
        }
    }
    
    func gameLoop(){
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (aTimer) in
            if self.checkGameStatus(){
                aTimer.invalidate()
                self.gameModel.doLoop = false
                print("Game is over")
                self.stopClouds()
                self.gameOverLabel.text = "Game Over"
                self.gameModel.player.stop()
                self.airplane.distance += self.airplane.distance + self.computeDistanceForCurrentSpeed()
                if self.postGameController.isTopTenGame(airplane: self.airplane) {
                    self.postGameController.storeGame(airplane: self.airplane, gameModel: self.gameModel)
                }
            }
              
            if self.gameModel.doLoop {
                if self.didCollide(){
                    self.airplane.speed = self.airplane.speed - (self.airplane.speed * 0.25)
                    self.airplane.distance += self.gameModel.distanceTimestampPerSpeed[self.gameModel.distanceTimestampPerSpeed.count-1].distanceInMeter
                    self.gameModel.distanceTimestampPerSpeed.append(DistanceMeasurement(speed: self.airplane.speed))
                    self.speedLabel.text = String(self.airplane.speed)
                                print("Crashed with cloud")
                }
                            
                self.computeWind()
                self.removeCloud()
                self.createCloud()
                self.gameModel.runningTime = aTimer.fireDate.timeIntervalSince(self.gameModel.startDate)
                self.updateValues()
            }
        }
    }

    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

struct GameResult: Codable{
    var distance: Double
    var runningTime: Double
    var startedAt: Date
    var endingSpeed: Double
    var crashReason: Bool
    
    init(distance: Double, runningTime: Double, startedAt: Date, endingSpeed: Double, crashReason: Bool) {
        self.distance = distance
        self.runningTime = runningTime
        self.startedAt = startedAt
        self.endingSpeed = endingSpeed
        self.crashReason = crashReason
    }
    
    func description() -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        return "Flight Time: \(self.runningTime) seconds, Started At: \(formatter.string(for: self.startedAt)!). Ending Speed: \(self.endingSpeed) kmh. Crash Reason: \(self.crashReason ? "Time" : "Speed")"
    }
}

struct DistanceMeasurement {
    var secondsActive: Double = 0.0
    var distanceInMeter: Double = 0.0
    var speed: Double
    let createdAt = Date()
    
    init(speed: Double){
        self.speed = speed
    }
}

extension Double{
    func roundToDecimal(_ digs: Int) -> Double {
        let multiplier = pow(10, Double(digs))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension Date{
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}
