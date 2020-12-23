//
//  GameViewController.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 11.12.20.
//

import UIKit

class GameViewController: UIViewController {
    
    let fileManager = FileManager.default
    var fileManagerUrls: [URL] = [URL]()
    
    let startDate = Date()
    let screenWidth = UIScreen.main.fixedCoordinateSpace.bounds.width
    let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height
    
    var cloudSpawnY: Float = 0
    var airplaneWidth: CGFloat = 0
    var clouds: Array<Cloud> = Array()
    var cloudFabric: CloudFabric = CloudFabric()
    var airplane = Airplane()
    
    var difficulty = 200
    var minSpawnDistance = 1.0
    var cloudSpeed = 2.0
    var loops = 0
    
    var distanceTimestampPerSpeed : Array<DistanceMeasurement> = Array()
                
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var background: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //background.image = UIImage(named: "background")
        //background.contentMode = .scaleAspectFill
        fileManagerUrls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        cloudSpawnY = Float(screenHeight - 20.0)
        self.view.addSubview(airplane.image)
        timeLabel.text = String(120.0)
        speedLabel.text = String(airplane.speed)
        distanceLabel.text = String(airplane.distance)
        distanceTimestampPerSpeed.append(DistanceMeasurement(speed: airplane.speed))
        
        
        gameLoop()
    }

    @IBAction func moveAirplane(_ sender: UISlider) {
        airplane.image.center.x = ((screenWidth/2) + (CGFloat(sender.value) * 300)) - 150
    }
    
    func computeMovement(slider: Float){
        
    }
    
    func didCollide() -> Bool {
        for index in clouds.indices {
            if(clouds[index].collided == false && clouds[index].image.frame.intersects(airplane.image.frame)){
                clouds[index].collided = true
                print("Cloud is in same frame as airplane")
                return true
            }
        }
        return false
    }

    
    func updateValues(runningTime: TimeInterval){
        loops += 1
    
        timeLabel.text = String(Double(120.0 - runningTime).roundToDecimal(2))
        speedLabel.text = String(airplane.speed.roundToDecimal(2))
        
        distanceTimestampPerSpeed[distanceTimestampPerSpeed.count-1].distanceInMeter = computeDistanceForCurrentSpeed()
        distanceLabel.text = String((airplane.distance + distanceTimestampPerSpeed[distanceTimestampPerSpeed.count-1].distanceInMeter).roundToDecimal(2))
    }
    
    func computeDistanceForCurrentSpeed() -> Double{
        let temp = distanceTimestampPerSpeed[distanceTimestampPerSpeed.count-1]
        let meterPerSeconds = airplane.speed / 3.6
        let secondsWithThisSpeed = temp.createdAt.distance(to: Date())
        return meterPerSeconds * secondsWithThisSpeed
    }
    
    /**
            true = game is over
            false = game is not over
     */
    func checkGameStatus(timeDifference: TimeInterval) -> Bool{
        if timeDifference >= self.airplane.maxTime {
            return true
        }else if airplane.speed <= airplane.demolitionSpeed {
            return true
        }
        return false
    }
    
    func manageClouds(){
        self.removeCloud()
        self.createCloud()
    }
    
    func createCloud(){
        let distanceToLatest = self.clouds.last?.date.distance(to: Date())
        if self.clouds.count == 0 || self.clouds.count < 5 && distanceToLatest! > self.minSpawnDistance {
            let mod = self.loops % self.difficulty
            if mod == 0{
                let c = self.cloudFabric.createCloud()
                self.view.addSubview(c.image)
                self.clouds.append(c)
                print("Cloud created. ", self.clouds.count, " are active.")
            }
        }
    }
    
    func removeCloud(){
        for (i, cloud) in self.clouds.enumerated().reversed() {
            cloud.image.frame.origin.y += CGFloat(self.cloudSpeed)
            if cloud.image.frame.origin.y > self.screenHeight{
                self.clouds.remove(at: i)
                print("Cloud delete")
            }
        }
    }
    
    func gameLoop(){
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (aTimer) in
            if self.didCollide(){
                self.airplane.speed = self.airplane.speed - (self.airplane.speed * 0.25)
                self.airplane.distance += self.distanceTimestampPerSpeed[self.distanceTimestampPerSpeed.count-1].distanceInMeter
                self.distanceTimestampPerSpeed.append(DistanceMeasurement(speed: self.airplane.speed))
                self.speedLabel.text = String(self.airplane.speed)
                print("crash!")
            }
            
            self.manageClouds()
            
            let timeDifference = aTimer.fireDate.timeIntervalSince(self.startDate)
            
            if self.checkGameStatus(timeDifference: timeDifference){
                aTimer.invalidate()
                print("END")
                self.gameOverLabel.text = "Game Over"
                if self.isTopTenGame() {
                    self.storeGame(runningTime: timeDifference)
                }
            }
            
            self.updateValues(runningTime: timeDifference)
        }
    }
    
    static func getGameResultArray() -> [GameResult] {
        do {
            if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                let fileURL = docDir.appendingPathComponent("results.txt")
                let jsonString = try String(contentsOf: fileURL)
                print("jsonString:", jsonString)
                let jsonData = jsonString.data(using: .utf8) ?? Data()
                let array = try JSONDecoder().decode([GameResult].self, from: jsonData)
                print("Saved new game result list successfully.")
                return array
            }
        }catch {
            print("Error while saving game result list.")
        }
        return [GameResult]()
    }
    
    func isTopTenGame() -> Bool {
        let gameResultArray = GameViewController.getGameResultArray()
        for gameResult in gameResultArray{
            if airplane.distance > gameResult.distance {
                return true
            }
        }
        
        if gameResultArray.count < 10 {
            return true
        }
        
        return false
    }
    
    func replaceOrAddGameResult(newGameResult: GameResult) -> [GameResult] {
        var gameResults = GameViewController.getGameResultArray()
        gameResults = gameResults.sorted(by: {$0.distance > $1.distance})
        
        if gameResults.count > 9 {
            gameResults.removeLast()
        }
        
        gameResults.append(newGameResult)
        gameResults = gameResults.sorted(by: {$0.distance > $1.distance})
        return gameResults
    }
    
    func storeGame(runningTime: TimeInterval){
        var gameResultArray = GameViewController.getGameResultArray()
        let result = GameResult(distance: self.airplane.distance.roundToDecimal(2), runningTime: runningTime.roundToDecimal(2), startedAt: startDate, endingSpeed: airplane.speed.roundToDecimal(2), crashReason: airplane.crashReason)
        
        gameResultArray = replaceOrAddGameResult(newGameResult: result)

        let json = try! JSONEncoder().encode(gameResultArray)
        let jsonString = String(data: json, encoding: .utf8)!
        
        print(jsonString)
        do {
            if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let fileURL = docDir.appendingPathComponent("results.txt")
                try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)
                print("Saved new game result list successfully.")
            }
        }catch {
            print("Error while saving game result list.")
        }
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
        return "Running Time: \(self.runningTime) Started At: \(self.startedAt.stripTime().description). Ending Speed: \(self.endingSpeed). Crash Reason: \(self.crashReason ? "Time" : "Speed")"
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
