//
//  CloudFabric.swift
//  FlightSimulator
//
//  Created by Mario Teklic on 14.12.20.
//

import UIKit

class CloudFabric {
    
    let screenWidth = UIScreen.main.fixedCoordinateSpace.bounds.width
    let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height
    
    func createCloud() -> Cloud{
        let x = CGFloat(Int.random(in: 35..<Int(screenWidth - 35)))
        let imgView = UIImageView(image: UIImage(imageLiteralResourceName: "wolke"))
        let size = CGFloat(Double.random(in: 0.08..<0.2))
        imgView.frame = CGRect(x: x, y: 0, width: screenWidth * size, height: screenWidth * size)
        
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position"
        animation.duration = 60
        animation.isAdditive = true
        animation.values = (0..<300).map({(y: Int) -> NSValue in
            let yPos = CGFloat(y)
            let xPos = sin(yPos)
            let point = CGPoint(x: xPos * 20, y: yPos)
            return NSValue(cgPoint: point)
        })
        
        imgView.layer.add(animation, forKey: "basic")

        return Cloud(image: imgView, date: Date())
    }
    
}

struct Cloud {
    var image: UIImageView
    var date: Date
    var collided: Bool
    
    init(image: UIImageView, date: Date, collided: Bool = false) {
        self.image = image
        self.date = date
        self.collided = collided
    }
}
