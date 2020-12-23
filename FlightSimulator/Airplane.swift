//
//  Airplane.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 14.12.20.
//

import UIKit

class Airplane{
        
    var image: UIImageView
    
    let screenWidth = UIScreen.main.fixedCoordinateSpace.bounds.width
    let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height
    
    /**
                speed = current speed
                range = range of flight in meter
                duration = duration of flight time in seconds
     */
    
    var speed, distance, duration: Double
    
    /**
            demolitionSpeed = if speed == demolitionSpeed, airplane crashes
            maxTime = maximum time of flight
            consumption = consumption per in liter per hour

     */
    let demolitionSpeed, maxTime, consumption: Double
    
    /**
            true = 2 minutes
            false = crash because of demolition speed reached
     */
    var crashReason: Bool
    
    public init(){
        consumption = 2400
        speed = 847.00
        demolitionSpeed = 235
        maxTime = 120
        distance = 0
        duration = 0
        crashReason = false
        
        image = UIImageView(image: UIImage(imageLiteralResourceName: "airplane_red"))
        image.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        image.frame = CGRect(x: screenWidth/2, y: screenHeight/2, width: screenWidth * 0.2, height: screenWidth * 0.2)
        image.center.x = screenWidth/2
        image.center.y = screenHeight - 175
        print(screenHeight)
    }
    
    func getCurrentSpeed(){
        
    }
    
    func getCurrentAirplaneHeight(){
        
    }
    
}
