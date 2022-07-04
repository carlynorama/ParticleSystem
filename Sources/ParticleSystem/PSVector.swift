////
////  Vector.swift
////  Wind
////
////  Created by Labtanza on 6/22/22.
////
//
//import Foundation
//import SwiftUI
//
////TODO: Should I just be using CGVector? Make my own vector type?
////TODO:  The simd framework provides support for small vectors, that is, vectors that contain up to eight double-precision or sixteen single-precision values.
////https://developer.apple.com/documentation/accelerate/working_with_vectors
////https://developer.apple.com/documentation/vision/vnvector
////CGVector?
//
////MARK: Retrieve Vectors
////cant do Numeric or FloatingPoint easily b/c many numerics don't have trig
//
//
//
//struct PSVector {
//    let magnitude:Double
//    let theta:VAngle
//    
//    let i:Double
//    let j:Double
//    
//    init(x:Double, y:Double) {
//        self.i = x
//        self.j = y
//        self.theta = VAngle(x: x, y: y)
//        self.magnitude = Self.calculateMagnitude(x: x, y: y)
//    }
//    
//    init(i:Double, j:Double) {
//        self.magnitude = 1
//        self.i = i
//        self.j = j
//        self.theta = VAngle(x: i, y: j)
//    }
//    
//    init(_ radians:Double, magnitude:Double = 1.0) {
//        self.theta = VAngle(radians)
//        (self.i, self.j) = self.theta.vectorComponents
//        self.magnitude = magnitude
//    }
//    
//    init(degrees:Double, magnitude:Double = 1.0) {
//        self = Self.init(degrees.asRadians, magnitude: magnitude)
//    }
//    
//    static func calculateMagnitude(x a:Double, y b:Double) -> Double {
//        sqrt(a.sqrd + b.sqrd)
//    }
//
//}
//
//extension PSVector {
//    static func + (lhs:PSVector, rhs:PSVector) -> PSVector {
//        let x = lhs.i + rhs.i
//        let y = lhs.j + rhs.j
//        return PSVector(x: x, y: y)
//    }
//    
//    static func - (lhs:PSVector, rhs:PSVector) -> PSVector {
//        let x = lhs.i - rhs.i
//        let y = lhs.j - rhs.j
//        return PSVector(x: x, y: y)
//    }
//    
//    static prefix func - (vector: PSVector) -> PSVector {
//        return PSVector(x: -vector.i, y: -vector.j)
//    }
//    
//    static func += (lhs: inout PSVector, rhs: PSVector) {
//        lhs = lhs + rhs
//    }
//    
//    static func == (lhs: PSVector, rhs: PSVector) -> Bool {
//        return (lhs.i == rhs.i) && (lhs.j == rhs.j)
//    }
//    
//}
//
//
//
