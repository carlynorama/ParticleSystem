//
//  ParticleSystem.swift
//  Wind
//
//  Created by Labtanza on 6/19/22.
//  https://developer.apple.com/documentation/scenekit/scnparticlesystem

import Foundation
import SwiftUI


    
public extension ParticleSystem {
        struct Profile:Codable {
            
            //Spawning
            public var timeBetweenSpawnsInSeconds = 1.0
            
            //how much chaos
            public var angleRange:ClosedRange<Double>
            public var angleWobble:Double
            public var magnitudeRange:ClosedRange<Double>
            public var magnitudeWobble:Double
        }
    }

    fileprivate extension ParticleSystem.Profile {
        init() {
            timeBetweenSpawnsInSeconds = 1.0
            angleRange = 0...(2.0 * Double.pi)
            angleWobble = 0.2
            magnitudeRange = 0.01...0.3
            magnitudeWobble = 0.05
        }
    }

public extension ParticleSystem {
    
    final class ParticleManager {
        //Particle Storage
        public private(set) var particles = Set<Particle>()
        public var profile = Profile()
        
        //System Features
        private let maxCount = 1000
        //TODO: This should be determined by what/who exactly?
        private let visiblebounds = -1.25...1.25
        
        //Sub-Timing
        
        
        
        //Particle Representation
        public let particleRepresentation = Image(systemName: "sparkle")
        public private(set) var massRange = 0.01...1.0
        public private(set) var radiusRange = 0.01...1.0
        
        //Spawning
        //private var birthRate = 1.0
        public private(set) var origin = (x:0.0, y:0.0)
        
        //Emission Ranges -- Updateable
        //        public private(set) var angleRange = 0...(2.0 * Double.pi)
        //        public private(set) var angleWobble = 0.2
        //        public private(set) var magnitudeRange = 0.01...0.3
        //        public private(set) var magnitudeWobble = 0.05
        
        public init() {}
        
        private var updateTime = Date.timeIntervalSinceReferenceDate
        
        
        //TODO: Particle add should stay here, but values should be udated by a data subscription?
        public func update(date:Date, direction:Double, magnitude:Double, origin:(Double, Double)) {
            
            updateOrigin(origin)
            updateStartingVelocity(direction: direction, magnitude: magnitude)
            
            if particles.count < maxCount && checkTimer(currentTime: date.timeIntervalSinceReferenceDate) {
                addParticle()
            }
        }
        
        public func updateStartingVelocity(direction:Double, magnitude:Double) {
            profile.angleRange = (direction - profile.angleWobble)...(direction + profile.angleWobble)
            profile.magnitudeRange = max((magnitude - profile.magnitudeWobble), 0.01)...(magnitude + profile.magnitudeWobble) //always a little
            
        }
        
        public var birthRatePerSecond:Double {
                1/(profile.timeBetweenSpawnsInSeconds)
        }
         
         public func updateOrigin(_ newCoords:(Double, Double)){
             self.origin = newCoords
             //print("origin - \(self.origin.x), \(self.origin.y)")
         }
         
         public func updateOrigin(_ x:Double, _ y:Double) {
             self.origin = (x,y)
             //print("origin - \(self.origin.x), \(self.origin.y)")
         }
        
        //TODO: Replace with clock??? 
        private func checkTimer(currentTime: Double) -> Bool {
            if currentTime > updateTime {
                updateTime = currentTime + profile.timeBetweenSpawnsInSeconds
                return true
            } else {
                return false
            }
        }
        
        func addParticle() {
            particles.insert(createParticle())
        }
        
        func remove(_ particle:Particle) {
            particles.remove(particle)
        }
        
        public func particleLocation(for particle:Particle, when timeInterval:Double) -> (x:Double, y:Double)? {
            let interval = timeInterval - particle.creationDate
            
            let distanceToTravel = particle.startVelocity * interval
            let position = particle.startPosistion + distanceToTravel
            
            //TODO: Rewrite using simd? Don't like that his is done in here at all actually
            //At somepoint there should be a particle store cleaner? Asyc on an actor style?
            if visiblebounds.contains(position.x) && visiblebounds.contains(position.y) {
                //if bounds.contains(CGPoint(x: x, y: y)) {
                return (x:position.x, y:position.y)
            } else {
                remove(particle)
                print("particle count: \(particles.count)")
                return nil
            }
            
            
        }
        
        
        
        func createParticle(x:Double, y:Double, direction:Double, magnitude:Double) -> Particle {
            let j = sin(direction) * magnitude
            let i = cos(direction) * magnitude
            //print("direction: \(direction) i: \(i) j: \(j)")
            return Particle (
                startPosistion: PSVector(x,y),
                startVelocity: PSVector(i,j),
                mass: Double.random(in: massRange),
                radius: Double.random(in: radiusRange)
            )
        }
        
        //can't use variable as a default
        func createParticle() -> Particle {
            let direction = Double.random(in: profile.angleRange)//Angle(degrees: 30).radians//1.0 * Double.pi //
            let maginitude = Double.random(in: profile.magnitudeRange)
            return createParticle(x: origin.x, y: origin.y, direction: direction, magnitude: maginitude)
        }
    }
}
