//
//  GameViewController.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 11.12.20.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    
    /*
     Enemy Fabric
     */
    var enemyFabric: EnemyFabric = EnemyFabric()
    
    /*
     Airplane
     */
    var airplane = Airplane()
    
    /*
     Game Model
     */
    var gameModel: GameModel = GameModel()
    
    /*
     Post Game Controller
     */
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
        initialize()
        gameLoop()
    }
    
    private func initialize(){
        //Variables
        var diffi = UserDefaults.standard.float(forKey: Constants.DIFFICULTY_OPTION) * 400
        if diffi < 1 {
            diffi = 1
        }
        gameModel.maxRandom = gameModel.maxRandom - Int(diffi)
        gameModel.cloudSpeed = gameModel.cloudSpeed + Double(diffi/150)
        gameModel.difficulty = Int(diffi)
        gameModel.fileManagerUrls = gameModel.fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        gameModel.cloudSpawnY = Float(screenHeight - 20.0)
        
        //Views
        self.view.addSubview(airplane.image)
        timeLabel.text = String(airplane.maxTime)
        speedLabel.text = String(airplane.speed)
        distanceLabel.text = String(airplane.distance)
        difficultyLabel.text = String(Double(diffi).roundToDecimal(2))
        gameModel.distanceTimestampPerSpeed.append(DistanceMeasurement(speed: airplane.speed))
        
        //Music
        do {
            let musicOption = UserDefaults.standard.string(forKey: Constants.MUSIC_OPTION)

            if musicOption == Constants.MUSIC_FUNNY ||
                musicOption == Constants.MUSIC_HIGHWAY ||
                musicOption == Constants.MUSIC_SYNTH {
                let url = Bundle.main.url(forResource: musicOption?.lowercased(), withExtension: "mp3")
                gameModel.player = try AVAudioPlayer(contentsOf: url!)
                gameModel.player.play()
            }else{
                showToast(message: "No music match!")
            }
            
           } catch let error as NSError {
               print("Failed to init audio player: \(error)")
           }
    }
    
    /*
     Stops the game loop and stops the background music
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameModel.doLoop = false
        gameModel.player.stop()
        print("Game loop stopped.")
    }
    
    /*
     Plays the background music
     */
    @IBAction func onMusicOnButtonClicked(_ sender: UIButton) {
        showToast(message:  "Music on.")
        musicOnButton.isHidden = true
        musicOffButton.isHidden = false
        gameModel.player.play()
    }
    
    /*
     Pauses the background music
     */
    @IBAction func onMusicOffButtonClicked(_ sender: UIButton) {
        showToast(message:  "Music off.")
        musicOnButton.isHidden = false
        musicOffButton.isHidden = true
        gameModel.player.pause()
    }
    
    /*
     Calculates the airplane movement, according to the slider movement
     */
    @IBAction func moveAirplane(_ sender: UISlider) {
        airplane.image.center.x = ((CGFloat(screenWidth/2)) + (CGFloat(sender.value) * 300)) - 150
    }
    
    /*
     Calculates, if the airplane has collided with one of the enemies
     */
    func didCollide() -> Bool {
        for index in gameModel.enemies.indices {
            if(gameModel.enemies[index].collided == false && gameModel.enemies[index].image.frame.intersects(airplane.image.frame)){
                gameModel.enemies[index].collided = true
                gameModel.enemies[index].image.backgroundColor = UIColor.red
                print("Cloud is in same frame as airplane")
                return true
            }
        }
        return false
    }
    
    /*
     Updates all labels according to the up-to-date values:
     Time, Speed and Distance.
     */
    func updateValues(){
        gameModel.loops += 1
    
        timeLabel.text = String(Double(airplane.maxTime - gameModel.runningTime).roundToDecimal(2))
        speedLabel.text = String(airplane.speed.roundToDecimal(2))
        
        gameModel.distanceTimestampPerSpeed[gameModel.distanceTimestampPerSpeed.count-1].distanceInMeter = computeDistanceForCurrentSpeed()
        distanceLabel.text = String((airplane.distance + gameModel.distanceTimestampPerSpeed[gameModel.distanceTimestampPerSpeed.count-1].distanceInMeter).roundToDecimal(2))
    }
    
    /*
     Computes the covered distance for the current speed
     */
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
    /*
     Checks if the game is over or not.
     True: Game is over
     False: Game is not over
     */
    func checkGameStatus() -> Bool{
        if gameModel.runningTime >= self.airplane.maxTime {
            return true
        }else if airplane.speed <= airplane.demolitionSpeed {
            return true
        }
        return false
    }

    /*
     Calls the EnemyFabric, to create an new enemy if following conditions are true:
      -> The distance (in time) to the latest spawned enemy is bigger than the minimum spawn distance (in time)
      -> Less then 5 enemies are on the field
      -> Or everytime if: no enemy is on the field/in the air
     */
    func createEnemy(){
        let distanceToLatest = gameModel.enemies.last?.date.distance(to: Date())
        if gameModel.enemies.count == 0 || gameModel.enemies.count < 5 && distanceToLatest! > gameModel.minSpawnDistance {
            
            let random = Int.random(in: 0..<gameModel.maxRandom)
            if random < gameModel.difficulty{
                let c = self.enemyFabric.createEnemy()
                self.view.addSubview(c.image)
                gameModel.enemies.append(c)
                print("Cloud created. ", gameModel.enemies.count, " are active.")
            }
        }
    }
    
    /*
     Moves a cloud according wind and cloud speed
     */
    func moveEnemy(enemy: Enemy){
        enemy.image.frame.origin.y += CGFloat(gameModel.cloudSpeed)
        enemy.image.frame.origin.x += CGFloat(gameModel.wind)
    }
    
    /*
     Removes enemies if the enemy has been disappeared from the screen
     */
    func removeEnemy(){
        for (i, enemy) in gameModel.enemies.enumerated().reversed() {
            moveEnemy(enemy: enemy)
            if enemy.image.frame.origin.y > CGFloat(screenHeight){
                gameModel.enemies.remove(at: i)
                print("Enemy delete")
            }
        }
    }
    
    /*
     Computes the wind, according to the game difficulty.
     Only has effect, when difficulty is +200
     */
    func computeWind(){
        if(gameModel.wind < 5 && gameModel.difficulty > 200){
            gameModel.wind += Double((gameModel.difficulty / 400))
        }
    }
    
    /*
     Stops all enemies
     */
    func stopEnemies(){
        gameModel.enemies.forEach{enemy in
            enemy.image.layer.removeAllAnimations()
        }
    }
    
    /*
     Game loop
     */
    func gameLoop(){
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (aTimer) in
            if self.checkGameStatus(){
                aTimer.invalidate()
                self.gameModel.doLoop = false
                print("Game is over")
                self.stopEnemies()
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
                self.removeEnemy()
                self.createEnemy()
                self.gameModel.runningTime = aTimer.fireDate.timeIntervalSince(self.gameModel.startDate)
                self.updateValues()
            }
        }
    }

    /*
     Shows a Toast for a short time.
     */
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

/*
 Represents a game result
 */
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

/*
 Distance Measurement represents a covered distance for a specific speed and time
 */
struct DistanceMeasurement {
    var secondsActive: Double = 0.0
    var distanceInMeter: Double = 0.0
    var speed: Double
    let createdAt = Date()
    
    init(speed: Double){
        self.speed = speed
    }
}

/*
 Extension, which cuts a Double in specific decimals
 E.g. 3.1415926535 -> 3.1415926535.roundToDecimal(digs: 2) -> 3.14
 */
extension Double{
    func roundToDecimal(_ digs: Int) -> Double {
        let multiplier = pow(10, Double(digs))
        return Darwin.round(self * multiplier) / multiplier
    }
}

/*
 Extension for a Date, which takes only year, month and day as components
 */
extension Date{
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}
