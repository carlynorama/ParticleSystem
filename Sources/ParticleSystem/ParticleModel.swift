//
//  ParticleModelExample.swift
//  Wind
//
//  Created by Labtanza on 6/19/22.
//

import Foundation

public extension ParticleSystem {
    struct Particle: Hashable {
        //identity
        let id = UUID()
        
        //initial conditions upon entering system
        let creationDate = Date.now.timeIntervalSinceReferenceDate
        public let startPosistion:PSVector
        public let startVelocity:PSVector
        
        public let startRotation:PSVector
        public let startSpinVelocity:PSVector  //SIUnit radians per second
        public let rotationPoint = PSVector(0,0)
        
        
        //physical properties
        let mass: Double
        let radius: Double
        
        public var age:Double {
            Date.now.timeIntervalSinceReferenceDate - creationDate
        }
        
        // density of water at 4°C is 1000.0    kg/m3 or 1.0      g/ml
        // density of air at   5°C is    1.2690 kg/m3 or 0.001269 g/ml
        // density of air at  20°C is    1.2041 kg/m3 or 0.001204 g/ml
        public var density:Double {
            mass/radius
        }
        
        public static func ==(lhs: Particle, rhs: Particle) -> Bool {
            return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
