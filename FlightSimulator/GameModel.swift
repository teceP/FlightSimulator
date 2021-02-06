//
//  GameModel.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 06.02.21.
//

import Foundation
import AVFoundation

class GameModel{
    var doLoop = true
    var player = AVAudioPlayer()
    let fileManager = FileManager.default
    var fileManagerUrls: [URL] = [URL]()
    let startDate = Date()
    var runningTime = 0.0
    var cloudSpawnY: Float = 0
    var clouds: Array<Cloud> = Array()
    var difficulty = 200
    var minSpawnDistance = 1.0
    var cloudSpeed = 2.0
    var wind = 0.0
    var loops = 0
    var distanceTimestampPerSpeed : Array<DistanceMeasurement> = Array()
}
