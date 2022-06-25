//
//  ParticleModelExample.swift
//  Wind
//
//  Created by Labtanza on 6/19/22.
//

import Foundation

extension ParticleSystem {
    struct Particle: Hashable {
        //identity
        let id = UUID()
        
        //initial conditions upon entering system
        let creationDate = Date.now.timeIntervalSinceReferenceDate
        let startX: Double
        let startY: Double
        let start_vi:Double
        let start_vj:Double
        
        //physical properties
        let mass: Double
        let radius: Double
        
        var age:Double {
            Date.now.timeIntervalSinceReferenceDate - creationDate
        }
        
        static func ==(lhs: Particle, rhs: Particle) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
