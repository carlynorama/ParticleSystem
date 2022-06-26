# ParticleSystem

This package is for creating very simple particle systems. It is under rapid development being designed for internal use. Nothing is settled, but feel free to poke around.

[![Swift Version][swift-image]][swift-url]

## Installation

Requires:
    written Xcode 14 Beta
    Platform targets iOS 15 or later, MacOS 12 or later

It is changing A LOT. Currently would suggest downloading it and using it as a local package, snagging code snippets, or just looking at the [[references][references]] below.


## Usage example

```
struct ParticleView: View {
    var particleSystem: ParticleSystem.ParticleManager
    
    var referenceCenter = (x: 0.5, y: 0.5)
    
    @State var direction:Double
    var oppositeDirection:Double {
        direction + Double.pi
    }
    @State var magnitude:Double
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                
                particleSystem.update(date: timeline.date, direction: direction, magnitude: magnitude, origin: (x:0.0, y:0.0))
                let particleImage = context.resolve(particleSystem.image)
                
                var systemContext = context
                systemContext.translateBy(
                    x:referenceCenter.x * size.width,
                    y:referenceCenter.y * size.height
                )
                
                
                let contextAspectRatio = size.width / size.height
                let correctedHeight = size.height * min(contextAspectRatio, 1)
                let correctedWidth = size.width * 1/max(contextAspectRatio, 1)
                
                for particle in particleSystem.particles {
                    var particleContext = systemContext
                    
                    //Decided to keep the logic in the psys
                    var currentEmitterContext = systemContext
                    currentEmitterContext.translateBy(
                        x:particle.startX * correctedWidth,
                        y:particle.startY * correctedHeight
                        
                    )
                    var emitterMarker = context.resolve(Image(systemName: "square"))
                    emitterMarker.shading = .color(white: 0.0, opacity: (1/(particle.age)).clamped(to: 0...1))
                    currentEmitterContext.draw(emitterMarker, at: .zero)
                    
                    guard let position = particleSystem.particleLocation(for: particle, when: timeline.date.timeIntervalSinceReferenceDate) else {
                        continue
                    }
                    //print(position)
                    particleContext.translateBy(
                        x: position.x * correctedWidth,
                        y: position.y * correctedHeight)
                    
                    particleContext.draw(particleImage, at: .zero)
                }
                
            }
        }.ignoresSafeArea(.all)
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Slider(value: $direction, in: 0...(2*Double.pi))
                    //Slider(value: $windSpeed, in: 0...(2*Double.pi))
                    Slider(value: $magnitude, in: 0...5) //5 ~ 18 kph, 11 mph
                }
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
            }
    }
    
}
```

## Release History

* 0.0.0
    * Current State. Wouldn't exactly call it "released"


## References [references]

### SwiftUI Canvas in General
* https://developer.apple.com/videos/play/wwdc2021/10021/
* https://developer.apple.com/documentation/swiftui/add_rich_graphics_to_your_swiftui_app

### Swift/SwiftUI ParticleSystems
* https://www.hackingwithswift.com/articles/246/special-effects-with-swiftui
* https://www.hackingwithswift.com/plus/live-streams/fireworks

### General Package Creation/Documentation Tips
* [Package Swift Docs](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)
* [Making views work](https://www.appcoda.com/swift-packages-swiftui-views/) from a package
* [WWDC What's New in DocC](https://developer.apple.com/videos/play/wwdc2022/110368/)

## Contact and Contributing

Feature not yet available.

[swift-image]:https://img.shields.io/badge/swift-5.7-orange.svg
[swift-url]: https://swift.org/
