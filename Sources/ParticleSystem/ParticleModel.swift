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
        public let startX: Double
        public let startY: Double
        let start_vi:Double
        let start_vj:Double
        
        //physical properties
        let mass: Double
        let radius: Double
        
        public var age:Double {
            Date.now.timeIntervalSinceReferenceDate - creationDate
        }
        
        public static func ==(lhs: Particle, rhs: Particle) -> Bool {
            return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
