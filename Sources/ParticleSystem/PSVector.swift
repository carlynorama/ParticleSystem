////
////  Vector.swift
////  Wind
////
////  Created by Labtanza on 6/22/22.
////
//
import Foundation
import SwiftUI //For Vector Arithmatic Complaince if I want it in the future

//TODO: Use Accelrate instead???
//see https://swiftwithmajid.com/2020/06/17/the-magic-of-animatable-values-in-swiftui/
//import Accelerate
import simd

//wanted so can be wonton in terms of input types of public functions? but not yet done.
//import Numerics,


////https://developer.apple.com/documentation/accelerate/working_with_vectors
///https://developer.apple.com/documentation/accelerate/working_with_matrices
////https://developer.apple.com/documentation/vision/vnvector


public struct PSVector {
    //typealias ValidInputType = Real
    public typealias Basic = Float
    public typealias Triplet = SIMD3<Basic>
    public typealias Pair = SIMD2<Basic> //TODO: can't just call pair because using taht type alias already in package
    //TODO: as function of Basic??
    //Doesnot look like there is a way to decalre a 3x3 as a type.
    //There is simd_double3x3, maybe just punt everything to that
    public typealias Matrix3x3 = simd_float3x3
    static public let identityMatrix3x3 =  matrix_identity_float3x3 as Matrix3x3

    
    //By representing 2D coordinates as a three-element vector, you can
    //transform points using matrix multiplication. Typically,
    //the third component of the vector, z, is set to 1, which //
    //indicates that the vector represents a position in space.
    private var transformationVector:Triplet  //(x: 3, y: 2, z: 1)
    
    //How much does this slow the math down?
    var vectorPair:Pair {
        Pair(transformationVector.x, transformationVector.y)
    }
    
    var polarValue:(direction:Basic, magnitude:Basic) {
        let direction = angle
        let magnitude = length
        return (direction, magnitude)
    }
    
    public var point:(x:Double, y:Double) {
        (x: x, y: y)
    }
    
    public var x:Double {
        Double(transformationVector.x)
    }
    
    public var y:Double {
        Double(transformationVector.y)
    }
    
}

extension PSVector {
    init(_ x:Double, _ y:Double) {
        self.transformationVector = Triplet(x:Basic(x), y:Basic(y), z:1)
    }
    
    static func fromPolar(direction:Basic, magnitude:Basic) -> Triplet {
            let i = cos(direction) * magnitude
            let j = sin(direction) * magnitude
        return Triplet(x:i, y:j, z:1)
    }
    
    static func toPolar(x:Basic, y:Basic) -> (direction:Basic, magnitude:Basic) {
         let normalized = (simd_normalize(Pair(x,y)))
         let direction = atan2(normalized.x, normalized.y)
         let magnitude = simd_length(Pair(x,y))
         return (direction:direction, magnitude:magnitude)
    }
    
    init(direction:Basic, magnitude:Basic) {
        self.transformationVector = Self.fromPolar(direction: direction, magnitude: magnitude)
    }
    
    init(direction:Double, magnitude:Double) {
        self.transformationVector = Self.fromPolar(direction: Basic(direction), magnitude: Basic(magnitude))
    }
}

extension PSVector {
    
    //MARK: Distances
    //distance from 0,0
    //should have same result as sqrt(x^2 + y^2)
    var length:Basic {
        simd_length(vectorPair)
    }
    
    //should have same result as sqrt((ax-bx)^2 + (ay-by)^2))
    func distance(from a:Pair, to b:Pair) -> Basic {
        simd_distance(a, b)
    }
    
    public func distance(to b:Pair) -> Basic {
        distance(from: vectorPair, to: b)
    }
    
    //comapres the relative magnintudes of the distances
    func closestPoint(a:Pair, b:Pair) -> Pair {
        if simd_distance_squared(a, vectorPair) < simd_distance_squared(b, vectorPair) {
            return a
        } else {
            return b
        }
    }
    
    //MARK: Angles
    var normalized:Pair {
        simd_normalize(vectorPair)
    }
    
    var angle:Basic {
        atan2(normalized.x, normalized.y)
    }
    
    public var radians:Double {
        Double(angle)
    }
    
    public var asAngle:Angle {
        Angle(radians: radians)
    }
    
    //MARK: Multiball Transfomations
    
    func transformed(dx tx:Basic, dy ty:Basic, radians:Basic, xscale:Basic, yscale:Basic) -> Triplet{
        let rMatrix = makeRotationMatrix(radians: radians)
        let sMatrix = makeScaleMatrix(xScale: xscale, yScale: yscale)
        let tMatrix = makeTranslationMatrix(tx: tx, ty: ty)
        return tMatrix * rMatrix * sMatrix * transformationVector
    }
    
    
    //MARK: Translation
    
    //1 0 tx
    //0 1 ty
    //0 0 1
    func makeTranslationMatrix(tx:Basic, ty:Basic) -> Matrix3x3 {
        //identity matrices (matrices with ones along the diagonal, and zeros elsewhere)
        var matrix = Self.identityMatrix3x3
        
        matrix[2, 0] = tx
        matrix[2, 1] = ty
        
        return matrix
    }
    
    func translated(dx tx:Basic, dy ty:Basic) -> Triplet {
        let translationMatrix = makeTranslationMatrix(tx: tx, ty: ty)
        return translationMatrix * transformationVector
    }
    
    func translatedXY(dx tx:Basic, dy ty:Basic) -> (x:Basic, y:Basic) {
        let translated = translated(dx: tx, dy: ty)
        return (x:translated.x, y:translated.y)
    }
    
    public func movedBy(dx:Double, dy:Double) -> (x:Double, y:Double){
        let moved = translatedXY(dx: Basic(dx), dy: Basic(dy))
        return (Double(moved.x), Double(moved.y))
        
    }
    
    
    //TODO: Wouldn't it be great if I could do this? Initializer for Type Alias??
//    public func translatedXY(dx tx:any ValidInputType, dy ty:any ValidInputType) -> (x:Basic, y:Basic) {
//        //TODO: Throws if casting fails
//        let castTX = Basic(tx)
//        let castTY = Basic(ty)
//        return translatedXY(dx: castTX, dy: castTY)
//    }
    
    //MARK: Rotation
    
    public func rotated(radians:Double) -> PSVector {
        PSVector(transformationVector: rotated(radians: Basic(radians)))
    }
    
    func makeRotationMatrix(radians:Basic) -> Matrix3x3 {
        let rows = [
            simd_float3(cos(radians), -sin(radians), 0),
            simd_float3(sin(radians), cos(radians),  0),
            simd_float3(           0,            0,  1)
        ]
        
        return Matrix3x3(rows: rows)
    }
    
    func rotated(radians:Basic) -> Triplet {
        let rotationMatrix = makeRotationMatrix(radians: radians)
        return rotationMatrix * transformationVector
    }
    
    func polarRotated(radians:Basic) -> (direction:Basic, magnitude:Basic) {
        let rotated = rotated(radians:radians)
        return Self.toPolar(x: rotated.x, y: rotated.y)
    }
    
    
    //MARK: Scale
    
    func makeScaleMatrix(xScale:Basic, yScale:Basic) -> Matrix3x3 {
        let rows = [
            simd_float3(xScale,      0, 0),
            simd_float3(     0, yScale, 0),
            simd_float3(     0,      0, 1)
        ]
        
        return Matrix3x3(rows: rows)
    }
    
    func scaled(xScale:Basic, yScale:Basic) -> Triplet{
        let scaleMatrix = makeScaleMatrix(xScale: xScale, yScale: yScale)
        return scaleMatrix * transformationVector
    }
    
    func scaled(by scale:Basic) -> Triplet{
        scaled(xScale: scale, yScale: scale)
    }
    
    
    
}


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
extension PSVector:VectorArithmetic {
    public static var zero:PSVector {
        return Self(transformationVector: Triplet(0,0,0))
    }
    
    public mutating func scale(by rhs: Double) {
        self.transformationVector = self.scaled(by: Basic(rhs))
    }

    public var magnitudeSquared: Double {
        //square everyone and sum
        Double((self.transformationVector * self.transformationVector).sum())
    }
    
    public static func + (lhs:PSVector, rhs:PSVector) -> PSVector {
//        let x = lhs.i + rhs.i
//        let y = lhs.j + rhs.j
        let new = lhs.transformationVector + rhs.transformationVector
        return Self(transformationVector: new)
    }
    
    static func * (lhs:PSVector, rhs:Basic) -> PSVector {
        let new = lhs.transformationVector * rhs
        return Self(transformationVector: new)
    }
    
    static func * (lhs:PSVector, rhs:Double) -> PSVector {
       return lhs * Basic(rhs)
    }
    
    public static func - (lhs:PSVector, rhs:PSVector) -> PSVector {
        //let x = lhs.i - rhs.i
        //let y = lhs.j - rhs.j
        let new = lhs.transformationVector - rhs.transformationVector
        return Self(transformationVector: new)
    }
    
    //Rotate 180 degrees, so each component * -1
    static prefix func - (vector: PSVector) -> PSVector {
        let new = vector.transformationVector * -1
        return Self(transformationVector: new)
    }
    
    public static func += (lhs: inout PSVector, rhs: PSVector) {
        lhs = lhs + rhs
    }
    
    public static func == (lhs: PSVector, rhs: PSVector) -> Bool {
        return (lhs.transformationVector == rhs.transformationVector)
    }
    
}

extension PSVector {
    static var randomNormalized:PSVector {
        let random = Double.random(in:0...Double.pi*2)
        return PSVector(direction: random, magnitude: 1)
    }
}
