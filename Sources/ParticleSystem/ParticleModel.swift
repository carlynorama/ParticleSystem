//
//  ParticleModelExample.swift
//  Wind
//
//  Created by Carlyn Maw on 6/19/22.
//

import Foundation

//TODO: get a little clearer about the units in documentaion
//TODO: Confirm radian/second of startSpinVeloctiy

public extension ParticleSystem {
    ////The data model for a particle
    ///
    ///What a particle knows about its self.
    struct Particle: Hashable {
        ///Identity for Hashable and Equitable conformance.
        let id = UUID()
        
        //MARK: initial conditions upon entering system
        let creationDate = Date.now.timeIntervalSinceReferenceDate
        
        ///location at creation, typically a value between -0.5 and 0.5 or 0 and 1
        public let startPosistion:PSVector
        ///velocity vector at creation
        public let startVelocity:PSVector
        ///orientation at creation. Retrievable as a direction between -π and π
        public let startRotation:PSVector
        ///Radians per second
        public let startSpinVelocity:Double
        
        //MARK: physical properties
        ///A number from 0 to 1 that represents a new particles relative mass to a particle system norm.
        let mass: Double
        ///A number from 0 to 1 that represents a new particles relative radius to a particle system norm.
        public let radius: Double
        
        //TODO: Center of gravity for spin, can also for angular?
        //public let rotationPoint = PSVector(0.0,0.0)
        
        ///Age of particle at time accessed in seconds
        public var age:Double {
            Date.now.timeIntervalSinceReferenceDate - creationDate
        }
        

        ///A unitless result of the mass / 3.14*radius^2
        ///
        ///Common densities for reference:
        ///density of water at 4°C is 1000.0       kg/m3 or 1.0           g/ml
        ///density of air at      5°C is       1.2690 kg/m3 or 0.001269 g/ml
        ///density of air at    20°C is       1.2041 kg/m3 or 0.001204 g/ml
        public var density:Double {
            //if 3d change to volume = (4/3) * π * pow(radius,3)
            let area = (3.14) * pow(radius,2)
            return mass/area
        }
        
        //MARK: Hashable Protocol Conformance
        public static func == (lhs: Particle, rhs: Particle) -> Bool {
            return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
