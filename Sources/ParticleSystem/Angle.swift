//
//  Angle.swift
//  Wind
//
//  Created by Labtanza on 6/22/22.
//

import Foundation

//TODO: Should I just extend SwiftUI Angle? Double?
//TODO: Is there a class of "that for which trig functions are defined?"

struct VAngle {
    typealias Magnitude = Double

    let magnitude: Magnitude

    init(_ vector:(i:Double, j:Double)){
        magnitude = atan2(vector.j, vector.i)
    }

    init(x:Double, y:Double){
        magnitude = atan2(x, y)
    }

    init(_ radians:Double){
        self.magnitude = radians
    }

    init(degrees:Double) {
        self.magnitude = degrees.asRadians
    }

    var degrees:Double {
        self.magnitude.asDegrees
    }
    
    var radians:Double {
        self.magnitude
    }

    var vectorComponents:(i:Double, j:Double) {
        let i = cos(magnitude)
        let j = sin(magnitude)
        return (i, j)
    }
}

//MARK: Angle Conversions
extension FloatingPoint {
    var asDegrees:Self {
        (self/180) * .pi
    }
    
    //TODO: possibly should use M_1_PI or is that overkill / not an issue anymore?
    var asRadians:Self {
        self * 180 / .pi
    }
}

extension Int {
    var asRadians:Double {
        Double(self) * 180.0 / Double.pi
    }
}
