//
//  ParticleSystem.swift
//  Wind
//
//  Created by Labtanza on 6/19/22.
//  https://developer.apple.com/documentation/scenekit/scnparticlesystem

import Foundation
import SwiftUI

public extension ParticleSystem {
     final class ParticleManager {
        //Particle Storage
        public private(set) var particles = Set<Particle>()
        
        //System Features
        private let maxCount = 1000
        //TODO: Which is more "perfomant?"
        private let visiblebounds = -1.25...1.25
        
        //Sub-Timing
        private var birthRate = 1.0
        private var updateTime = Date.timeIntervalSinceReferenceDate
        
        //Particle Representation
        public let image = Image(systemName: "sparkle")
        public private(set) var massRange = 0.01...1.0
        public private(set) var radiusRange = 0.01...1.0
        
        //Emission Ranges -- Updateable
        public private(set) var origin = (x:0.0, y:0.0)
        public private(set) var angleRange = 0...(2.0 * Double.pi)
        public private(set) var angleWobble = 0.2
        public private(set) var magnitudeRange = 0.01...0.3
        public private(set) var magnitudeWobble = 0.05
         
        public init() {}
        
        
        //TODO: Particle add should stay here, but values should be udated by a data subscription?
        public func update(date:Date, direction:Double, magnitude:Double, origin:(Double, Double)) {
            
            self.origin = origin
            //print("origin - \(self.origin.x), \(self.origin.y)")
            angleRange = (direction - angleWobble)...(direction + angleWobble)
            magnitudeRange = max((magnitude - magnitudeWobble), 0.01)...(magnitude + magnitudeWobble)
            
            
            if particles.count < maxCount && checkTimer(currentTime: date.timeIntervalSinceReferenceDate) {
                addParticle()
            }
        }
        
        private func checkTimer(currentTime: Double) -> Bool {
            if currentTime > updateTime {
                updateTime = currentTime + birthRate
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
            let x = particle.startX + (particle.start_vi * interval)
            let y = particle.startY + (particle.start_vj * interval)
            
            if visiblebounds.contains(x) && visiblebounds.contains(y) {
                //if bounds.contains(CGPoint(x: x, y: y)) {
                return (x:x, y:y)
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
                startX: x,
                startY: y,
                start_vi: i,
                start_vj: j,
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
