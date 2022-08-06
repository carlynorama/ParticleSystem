//
//  ParticleManager.swift
//
//  Created by Carlyn Maw on 6/19/22.
//  https://developer.apple.com/documentation/scenekit/scnparticlesystem

//TODO: URGENT WHAT HAPPENS WHEN MAGNITUDE IS ZERO???

import Foundation

fileprivate extension ParticleSystem.PSProfile {
    ///Initializer for use by a ParticleManager to make sure no values are empty upon it's own initialization.
    init() {
        coreAngle = 0.0
        coreMagnitude = 0.15
        timeBetweenSpawnsInSeconds = 1.0
        angleWobble = Double.pi
        magnitudeWobble = 0.05
        coreSpinVelocity = 0.5
        spinWobble = 0.5
        coreMassValue = 0.5
        massWobble = 0.4
        coreRadiusValue = 0.5
        radiusWobble = 0.4
    }
}

public extension ParticleSystem {
    ///The heart of a ParticleSystem.
    ///
    ///The ParticleManager stores the particles in a Set.  It handles each particles creation and deletion. It additionally retrieves location, rotation and other information about each particle.
    //TODO: Actor?
    final class ParticleManager {
        
        
        public init() {}
        //MARK: Particle Storage
        
        ///The set of particles.
        public private(set) var particles = Set<Particle>()
        ///The profile settings. All runtime updatable features live in the the profile.
        
        
        //MARK: System Features
        //TODO: Should this be a private set? What about prototyping mode?
        public var profile = PSProfile()
        
        ///The maximum number of particles that can be managed by this particle system.
        //TODO: Make this part of an init.
        private let maxCount = 1000
        
        ///The birthrate in seconds rather than the time between spawns.
        public var birthRate:Double {
            1/(profile.timeBetweenSpawnsInSeconds)
        }
        
        public var fromDirection:Double {
            profile.coreAngle
        }
        
        public var toDirection:Double {
            profile.coreAngle + Double.pi
        }
        
        //TODO: This should be determined by what/who exactly?
        //TODO: Make this part of an init.
        ///The boundaries after which a particle will be removed from particle cloud.
        private let visiblebounds = -2.0...2.0
        
        //MARK: Spawning
        
        ///The location of a particles emmission relative to other particles in the system.
        ///In most applications this value will have a root of 0,0 and a range of -0.5 to 0.5 where the smallest dimension of the parent view is definitionally 1.
        ///The values are saved as (Double, Double) rather than PSVector because it is updated externally and only internally used during particle creation.
        ///Currently all ParticleSystems have only this point source.
        ///- Parameter x: the x coordinate
        ///- Parameter y: the y coordinate
        public private(set) var origin = (x:0.0, y:0.0)
        //TODO: emitters that aren't point sources??
        
        //MARK: Emission Ranges
        
        private func noNegativeRange(_ value:Double, percent:Double) -> ClosedRange<Double> {
            let factor = value * percent
            let lowerBound = max((value - factor), 0.0)
            let upperBound = value + factor
            return lowerBound...upperBound
        }
        
        private func noNegativeRange(_ value:Double, amount:Double) -> ClosedRange<Double> {
            let lowerBound = max((value - amount), 0.0)
            let upperBound = value + amount
            return lowerBound...upperBound
        }
        
        ///range of headings for new particles.
        private var angleRange:ClosedRange<Double> {
            (profile.coreAngle - profile.angleWobble)...(profile.coreAngle + profile.angleWobble)
        }
        
        ///range of speeds for new particles.
        private var magnitudeRange:ClosedRange<Double> {
            noNegativeRange(profile.coreMagnitude, percent: profile.magnitudeWobble)
        }
        ///range of rotational speed for new particles.
        private var spinVelocityRange:ClosedRange<Double> {
            noNegativeRange(profile.coreSpinVelocity, percent: profile.spinWobble)
        }
        
        ///range of masses for new particles.
        private var massRange:ClosedRange<Double> {
            noNegativeRange(profile.coreMassValue, amount: profile.massWobble)
        }
        
        ///range of radii for new particles.
        private var radiusRange:ClosedRange<Double> {
            noNegativeRange(profile.coreRadiusValue, amount: profile.radiusWobble)
        }
        
        
        
        //MARK: Public Updating
        
        ///Function to both update the starting condtions and spawn
        ///
        ///The update function updates the direction and magnitude of new particles, as well their origin point. Other types of profile information are not handled in the update. If it's time and there aren't already too many particles it will also spawn a new particle.
        ///- Parameter date: the timestamp from the calling funtion.
        ///- Parameter direction: new coreDirection
        ///- Parameter magnitude: new coreMagnitude
        ///- Parameter origin: new emitter location
        public func update(date:Date, direction:Double, magnitude:Double, origin:(Double, Double)) {
            
            updateOrigin(origin)
            updateStartingVelocity(direction: direction, magnitude: magnitude)
            
            if particles.count < maxCount && isTimeToSpawn(currentTime: date.timeIntervalSinceReferenceDate) {
                addParticle()
            }
        }
        
        ///Clear particle system of current particles and spawn delay.
        ///
        ///Leaves particle profile intact.
        public func clear() {
            particles.removeAll()
            nextTimeToSpawn = Date.timeIntervalSinceReferenceDate
        }
        
        public func clear(particle:Particle) {
            particles.remove(particle)
            //print("PManager, clear(): removed particle at \(particle.age) seconds old")
            //nextTimeToSpawn = Date.timeIntervalSinceReferenceDate
        }
        
        //TODO: Replace with clock???
        ///Deadline to spawn the next particle
        private var nextTimeToSpawn = Date.timeIntervalSinceReferenceDate
        
        ///Check to see if it's time to spawn.
        ///
        ///Uses a passed time, typically in from a ViewModel or a TimelineView, to check against the deadline, ``nextTimeToSpawn``.
        ///- Parameter currentTime: the time it is according to the caller.
        private func isTimeToSpawn(currentTime:Double) -> Bool {
            if currentTime > nextTimeToSpawn {
                //print("PManager, isTimeToSpawn:\(profile.timeBetweenSpawnsInSeconds)")
                nextTimeToSpawn = currentTime + profile.timeBetweenSpawnsInSeconds
                return true
            } else {
                return false
            }
        }
        
        ///passes a direction and magnitude to coreAngle and coreMagnitude
        private func updateStartingVelocity(direction:Double, magnitude:Double) {
            profile.coreAngle = direction
            profile.coreMagnitude = magnitude
        }
        ///updates coreAngle and coreMagnitude using a PSVector.
        private func updateStartingVelocity(_ vector:PSVector) {
            profile.coreAngle = vector.polarComponets.direction
            profile.coreMagnitude = vector.polarComponets.magnitude
        }
        
        ///passes a tuple of Doubles to origin. (x,y)
        private func updateOrigin(_ newCoords:(Double, Double)){
            self.origin = newCoords
        }
        
        ///passes an x and a y to the origin.
        private func updateOrigin(_ x:Double, _ y:Double) {
            self.origin = (x,y)
        }
        
        ///Add a particle to the set. Should only be called by an update function.
        private func addParticle() {
            particles.insert(createParticle())
        }
        
        ///Remove a particle to the set. Should only be called by an update function.
        private func remove(_ particle:Particle) {
            particles.remove(particle)
        }
        
        //MARK: Particle Behaviors
        
        ///Retrieves a particle location for a given time as a TimeInterval.
        public func particleLocation(for particle:Particle, when timeInterval:Double) -> (x:Double, y:Double)? {
            let interval = timeInterval - particle.creationDate
            
            let distanceToTravel = particle.startVelocity * interval
            let position = particle.startPosistion + distanceToTravel
            
            
            //TODO: Rewrite bounds check using simd?
            //TODO: Move to an async batch process?
            //At somepoint there should be a particle store cleaner? Asyc on an actor style?
            if visiblebounds.contains(position.x) && visiblebounds.contains(position.y) {
                return (x:position.x, y:position.y)
            } else {
                remove(particle)
                print("particle count: \(particles.count)")
                return nil
            }
        }
        
        ///Retrieves a particle rotation for a given time as a TimeInterval.
        public func particleRotation(for particle:Particle, when timeInterval:Double) -> Double {
            let interval = timeInterval - particle.creationDate
            
            let startVelocityRadians = particle.startSpinVelocity
            let deltaTheta = startVelocityRadians * interval
            let angle = particle.startRotation.rotatedBy(radians: deltaTheta).radians
            
            return angle
            
        }
        
        //MARK: Particle Creation
        
        ///Create a particle based on a location and velocity vector, using the profile settings for everything else.
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
        
        ///Create a random particle based on profile settings.
        func createParticle() -> Particle {
            let direction = Double.random(in: angleRange)
            let maginitude = Double.random(in: magnitudeRange)
            return createParticle(x: origin.x, y: origin.y, direction: direction, magnitude: maginitude)
        }
    }
}
