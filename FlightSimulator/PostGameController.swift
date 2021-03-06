//
//  PostGameController.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 06.02.21.
//

import Foundation

class PostGameController{
    
    /*
     Stores a Game Result Object
     */
    func storeGame(airplane: Airplane, gameModel: GameModel){
        var gameResultArray = PostGameController.getGameResultArray()
        let result = createGameResult(airplane: airplane, gameModel: gameModel)
        
        print("Try to store Object: ", result.description())

        gameResultArray = replaceOrAddGameResult(newGameResult: result)

        let json = try! JSONEncoder().encode(gameResultArray)
        let jsonString = String(data: json, encoding: .utf8)!
        
        do {
            if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let fileURL = docDir.appendingPathComponent("results.txt")
                try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)
            }
        }catch {
            print("Error while saving game result list.")
        }
    }
    
    /*
     Creates the GameResult Object according to the stats
     */
    func createGameResult(airplane: Airplane, gameModel: GameModel) -> GameResult {
        if(airplane.speed <= airplane.demolitionSpeed){
            airplane.crashReason = false
        }
                
        let result = GameResult(distance: airplane.distance.roundToDecimal(2), runningTime: gameModel.runningTime.roundToDecimal(2), startedAt: gameModel.startDate, endingSpeed: airplane.speed.roundToDecimal(2), crashReason: airplane.crashReason)
        
        return result
    }
    
    /*
     Replaces a game result, if the gameresult was better than any existing.
     Adds the game result if there where not 10 results yet.
     Adds the game result to the correct place.
     */
    func replaceOrAddGameResult(newGameResult: GameResult) -> [GameResult] {
        var gameResults = PostGameController.getGameResultArray()
        gameResults = gameResults.sorted(by: {$0.distance > $1.distance})
        
        if gameResults.count > 9 {
            gameResults.removeLast()
        }
        
        gameResults.append(newGameResult)
        gameResults = gameResults.sorted(by: {$0.distance > $1.distance})
        return gameResults
    }
    
    /*
     Checks, if this game was a top-ten-result
     */
    func isTopTenGame(airplane: Airplane) -> Bool {
        let gameResultArray = PostGameController.getGameResultArray()
        
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
    
    /*
     Restores the GameResult Array, which holds the top-ten results
     */
    static func getGameResultArray() -> [GameResult] {
        do {
            if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                let fileURL = docDir.appendingPathComponent("results.txt")
                let jsonString = try String(contentsOf: fileURL)
                let jsonData = jsonString.data(using: .utf8) ?? Data()
                let array = try JSONDecoder().decode([GameResult].self, from: jsonData)
                return array
            }
        }catch {
            print("Error while saving game result list.")
        }
        return [GameResult]()
    }
}
