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
        public var timeBetweenSpawnsInSeconds:Double
        
        //how much chaos
        public var coreAngle:Double
        public var angleWobble:Double

        public var coreMagnitude:Double
        public var magnitudeWobble:Double
        
        public var coreSpinVelocity:Double
        public var spinWobble:Double
        
        public var coreMassValue:Double
        public var coreRadiusValue:Double
        
    }
}
public extension ParticleSystem.Profile {
    init(coreAngle:Double = 0.0,
         coreMagnitude:Double = 0.15,
         spawnLag:Double = 1.0,
         angleWobble:Double = Double.pi,
         magnitudeWobble:Double = 0.05,
         coreSpinVelocity:Double = 0.5,
         spinWobble:Double = 0.5) {
        self.coreAngle = coreAngle
        self.coreMagnitude = coreMagnitude
        self.timeBetweenSpawnsInSeconds = spawnLag
        self.angleWobble = angleWobble
        self.magnitudeWobble = magnitudeWobble
        self.coreSpinVelocity = coreSpinVelocity
        self.spinWobble = spinWobble
        self.coreMassValue = 0.5
        self.coreRadiusValue = 0.5
    }
}

fileprivate extension ParticleSystem.Profile {
    init() {
    coreAngle = 0.0
    coreMagnitude = 0.15
    timeBetweenSpawnsInSeconds = 1.0
    timeBetweenSpawnsInSeconds = 1.0
    angleWobble = Double.pi
    magnitudeWobble = 0.05
    coreSpinVelocity = 0.5
    spinWobble = 0.5
        coreMassValue = 0.5
        coreRadiusValue = 0.5
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
        private let visiblebounds = -2.0...2.0
        
        //Sub-Timing
        
        
        
        //Particle Representation
        public let particleRepresentation = Image(systemName: "sparkle")
        
        //Spawning
        //private var birthRate = 1.0
        public private(set) var origin = (x:0.0, y:0.0)
        
        //Emission Ranges -- Updateable
        public var angleRange:ClosedRange<Double> {
            (profile.coreAngle - profile.angleWobble)...(profile.coreAngle + profile.angleWobble)
        }
  
        public var magnitudeRange:ClosedRange<Double> {
            max((profile.coreMagnitude - profile.magnitudeWobble), 0.01)...(profile.coreMagnitude + profile.magnitudeWobble) //always a little
        }
        
        public var spinVelocityRange:ClosedRange<Double> {
            max((profile.coreSpinVelocity - profile.spinWobble), 0.01)...(profile.coreSpinVelocity + profile.spinWobble) //always a little
        }
        
        public var massRange:ClosedRange<Double> {
            0.01...1.0
        }
        
        public var radiusRange:ClosedRange<Double> {
            0.01...1.0
        }
        
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
            profile.coreAngle = direction
            profile.coreMagnitude = magnitude
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
        private func checkTimer(currentTime:Double) -> Bool {
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
            
            
            //TODO: Rewrite bounds check using simd?
            //TODO: Move to an async batch process?
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
        
        public func particleRotation(for particle:Particle, when timeInterval:Double) -> Angle {
            let interval = timeInterval - particle.creationDate
            //Shimmy
            //let rotation = sin(interval)
            //let angle = particle.startRotation.rotated(radians: rotation).asAngle
            
            let startVelocityRadians = particle.startSpinVelocity
            let deltaTheta = startVelocityRadians * interval
            let angle = particle.startRotation.rotatedBy(radians: deltaTheta).asAngle
            
            return angle
            
        }
        
        func createParticle(x:Double, y:Double, direction:Double, magnitude:Double) -> Particle {
            Particle (
                startPosistion: PSVector(x,y),
                startVelocity: PSVector(direction: direction, magnitude: magnitude),
                startRotation: PSVector.randomNormalized,
                startSpinVelocity: Double.random(in: spinVelocityRange),
                mass: Double.random(in: massRange),
                radius: Double.random(in: radiusRange)
            )
        }
        
        //can't use variable as a default
        func createParticle() -> Particle {
            let direction = Double.random(in: angleRange)//Angle(degrees: 30).radians//1.0 * Double.pi //
            let maginitude = Double.random(in: magnitudeRange)
            return createParticle(x: origin.x, y: origin.y, direction: direction, magnitude: maginitude)
        }
    }
}
