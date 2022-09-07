//
//  PSProfile.swift
//  
//
//  Created by Carlyn Maw on 7/8/22.
//

import Foundation


public extension ParticleSystem {
    ///Data model for whats sharable and editable about a ParticleManager.
    ///
    ///This codable strut stores information that controls the behavior
    ///of the ParticleSystem.
    struct PSProfile:Codable {
        
        //Spawning
        
        ///The amount of time between each creation of a particle in seconds.
        public var timeBetweenSpawnsInSeconds:Double
        
        //how much chaos
        
        ///The direction componet of a new particle's velocity is equivalent to a FROM direction
        public var coreAngle:Double
        ///The amount of play in the direction a new particle will go
        public var angleWobble:Double

        ///The magnitude component of a new particle's velocity.
        ///Where a value of 1 represents the size of the parent views smaller dimension.
        public var coreMagnitude:Double
        ///The amount of play in how fast a new particle will go. As a ± percentage.
        public var magnitudeWobble:Double
        
        ///The amount, in radians, a new particle will spin per update
        public var coreSpinVelocity:Double
        ///The amount of play in how fast a particle will spin. As a ± percent.
        public var spinWobble:Double
        
        ///A number from 0 to 1 that represents a new particles relative mass to a particle system norm.
        public var coreMassValue:Double
        ///The amount of play in how much mass the particle will have. As a point change on the the scaler
        public var massWobble:Double
        
        ///A number from 0 to 1 that represents a new particles relative radius to a particle system norm.
        public var coreRadiusValue:Double
        ///The amount of play in the raduis of the particle. As a point change on the the scaler
        public var radiusWobble:Double
        
    }
}

extension ParticleSystem.PSProfile:Equatable {
    
}

public extension ParticleSystem.PSProfile {
    ///initializer that allows inputing each value in the struct, but provides defaults.
    init(coreAngle:Double = 0.0,
         coreMagnitude:Double = 0.15,
         spawnLag:Double = 1.0,
         angleWobble:Double = Double.pi,
         magnitudeWobble:Double = 0.05,
         coreSpinVelocity:Double = 0.5,
         spinWobble:Double = 0.5
    ) {
        self.coreAngle = coreAngle
        self.coreMagnitude = coreMagnitude
        self.timeBetweenSpawnsInSeconds = spawnLag
        self.angleWobble = angleWobble
        self.magnitudeWobble = magnitudeWobble
        self.coreSpinVelocity = coreSpinVelocity
        self.spinWobble = spinWobble
        self.coreMassValue = 0.5
        self.massWobble = 0.4
        self.coreRadiusValue = 0.5
        self.radiusWobble = 0.1
    }
}
