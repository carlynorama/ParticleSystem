////
////  Vector.swift
////  Wind
////
////  Created by Labtanza on 6/22/22.
////
//
import Foundation
import SwiftUI //For Vector Arithmatic Complaince if I want it in the future

//Note to self simd IS part of accelrate.
import simd

//wanted so can be wonton in terms of input types of public functions, but not yet done.
//import Numerics


////https://developer.apple.com/documentation/accelerate/working_with_vectors
///https://developer.apple.com/documentation/accelerate/working_with_matrices


public struct PSVector {
    //typealias ValidInputType = Real
    public typealias Basic = Float
    public typealias Triplet = SIMD3<Basic>
    public typealias Pair = SIMD2<Basic>
    //TODO: as function of Basic??
    //Doesnot look like there is a way to decalre a 3x3 as a type.
    //There is simd_double3x3, maybe just punt everything to that
    public typealias Matrix3x3 = simd_float3x3  //there is also simd_double3x3
    static public let identityMatrix3x3 =  matrix_identity_float3x3 as Matrix3x3

    //Why is data saved as a triplet (quaternian) intead os a pair?
    //see reccomendation https://developer.apple.com/documentation/accelerate/working_with_vectors
    //"By representing 2D coordinates as a three-element vector, you can
    //transform points using matrix multiplication. Typically,
    //the third component of the vector, z, is set to 1, which
    //indicates that the vector represents a position in space."
    //
    //Is a var to have animatable data conformance. TBD is really necessary.
    private var vectorTriplet:Triplet  //(x: 3, y: 2, z: 1)
    
    //TODO: How much does this being calculated slow the math down
    //hard code at init and have setters that update each other?
    private var vectorPair:Pair {
        Pair(vectorTriplet.x, vectorTriplet.y)
    }
    
    //TODO: How much does this being calculated slow the math down
    //hard code at init and have setters that update each other?
    private var polarValue:(direction:Basic, magnitude:Basic) {
        let direction = angleFromNormalized //TODO: probably don't need to normalize?
        let magnitude = length
        return (direction, magnitude)
    }
}


//MARK: Initializers
extension PSVector {
    init(_ x:Double, _ y:Double) {
        self.vectorTriplet = Triplet(x:Basic(x), y:Basic(y), z:1)
    }
    
    init(_ triplet:Triplet) {
        self.vectorTriplet = triplet
    }
    
    //TODO: WHY IS THIS BACKWARDS??? flips the coordinates when done correctly?
    static func fromPolar(direction:Basic, magnitude:Basic) -> Triplet {
            let x = cos(direction) * magnitude
            let y = sin(direction) * magnitude
        return Triplet(x:x, y:y, z:1)
    }
    
    static func toPolar(x:Basic, y:Basic) -> (direction:Basic, magnitude:Basic) {
         let normalized = (simd_normalize(Pair(x,y)))
         let direction = atan2(normalized.y, normalized.x)
         let magnitude = simd_length(Pair(x,y))
         return (direction:direction, magnitude:magnitude)
    }
    
    init(direction:Basic, magnitude:Basic) {
        self.vectorTriplet = Self.fromPolar(direction: direction, magnitude: magnitude)
    }
    
    init(direction:Double, magnitude:Double) {
        self.vectorTriplet = Self.fromPolar(direction: Basic(direction), magnitude: Basic(magnitude))
    }
}

//MARK: Data acessors
extension PSVector {
    
    public var components:(x:Double, y:Double) {
        (x: x, y: y)
    }
    
    public var x:Double {
        Double(vectorTriplet.x)
    }
    
    public var y:Double {
        Double(vectorTriplet.y)
    }
    
    public var polarComponets:(direction:Double, magnitude: Double) {
        let pc = polarValue
        return (Double(pc.direction), Double(pc.magnitude))
    }
    
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
    
    var angleFromNormalized:Basic {
        atan2(normalized.y, normalized.x)
    }
    
    var angleInRadians:Basic {
        atan2(vectorTriplet.y, vectorTriplet.x)
    }
    
    public var radians:Double {
        Double(angleFromNormalized)
    }
    
    public var asAngle:Angle {
        Angle(radians: radians)
    }
    
}

//MARK: Transformations
extension PSVector {
    
    //MARK: Multiball Transfomations
    
    func transformed(dx tx:Basic, dy ty:Basic, radians:Basic, xscale:Basic, yscale:Basic) -> Triplet{
        let rMatrix = makeRotationMatrix(radians: radians)
        let sMatrix = makeScaleMatrix(xScale: xscale, yScale: yscale)
        let tMatrix = makeTranslationMatrix(tx: tx, ty: ty)
        return tMatrix * rMatrix * sMatrix * vectorTriplet
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
        return translationMatrix * vectorTriplet
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
    
    public func rotatedBy(radians:Double) -> PSVector {
        PSVector(rotatedTriplet(radians: Basic(radians)))
    }
    
    func makeRotationMatrix(radians:Basic) -> Matrix3x3 {
        let rows = [
            Triplet(cos(radians), -sin(radians), 0),
            Triplet(sin(radians), cos(radians),  0),
            Triplet(           0,            0,  1)
        ]
        
        return Matrix3x3(rows: rows)
    }
    
    func rotatedTriplet(radians:Basic) -> Triplet {
        let rotationMatrix = makeRotationMatrix(radians: radians)
        return rotationMatrix * vectorTriplet
    }
    
//    func polarRotated(radians:Basic) -> (direction:Basic, magnitude:Basic) {
//        let rotated = rotatedTriplet(radians:radians)
//        return Self.toPolar(x: rotated.x, y: rotated.y)
//    }
    
    
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
        return scaleMatrix * vectorTriplet
    }
    
    func scaled(by scale:Basic) -> Triplet{
        scaled(xScale: scale, yScale: scale)
    }
    
    
    
}

//MARK: Arithmatic, Multiplication, Animatable
extension PSVector:Animatable {
    public static var zero:PSVector {
        return Self(vectorTriplet: Triplet(0,0,0))
    }
    
    public mutating func scale(by rhs: Double) {
        self.vectorTriplet = self.scaled(by: Basic(rhs))
    }
        
    //square and sum
    public var magnitudeSquared: Double {
        Double((self.vectorTriplet * self.vectorTriplet).sum())
    }
    
    //MARK: Additon & Subtraction
    
    //Should produce same result as
    //        let x = lhs.x + rhs.x
    //        let y = lhs.y + rhs.y
    // TODO: confirm Z behavior.
    public static func + (lhs:PSVector, rhs:PSVector) -> PSVector {
        let new = lhs.vectorTriplet + rhs.vectorTriplet
        return Self(vectorTriplet: new)
    }
    
    static func + (lhs:PSVector, rhs:Basic) -> PSVector {
        let new = lhs.vectorTriplet + rhs
        return Self(vectorTriplet: new)
    }
    
    static func + (lhs:PSVector, rhs:Double) -> PSVector {
       return lhs + Basic(rhs)
    }
    
    public static func - (lhs:PSVector, rhs:PSVector) -> PSVector {
        //let x = lhs.i - rhs.i
        //let y = lhs.j - rhs.j
        let new = lhs.vectorTriplet - rhs.vectorTriplet
        return Self(vectorTriplet: new)
    }
    
    //Rotate 180 degrees, so each component * -1
    static prefix func - (vector: PSVector) -> PSVector {
        let new = vector.vectorTriplet * -1
        return Self(vectorTriplet: new)
    }
    
    public static func += (lhs: inout PSVector, rhs: PSVector) {
        lhs = lhs + rhs
    }
    
    public static func -= (lhs: inout PSVector, rhs: PSVector) {
        lhs = lhs - rhs
    }
    
    //MARK: Multiplication
    
    static func * (lhs:PSVector, rhs:Basic) -> PSVector {
        let new = lhs.vectorTriplet * rhs
        return Self(vectorTriplet: new)
    }
    
    static func * (lhs:PSVector, rhs:Double) -> PSVector {
       return lhs * Basic(rhs)
    }
    
    //MARK: Equatable, Comparable
    
    public static func == (lhs: PSVector, rhs: PSVector) -> Bool {
        return (lhs.vectorTriplet == rhs.vectorTriplet)
    }
    
    public static func > (lhs: PSVector, rhs: PSVector) -> Bool {
        return (lhs.magnitudeSquared > rhs.magnitudeSquared)
    }
    
    
    
}

//MARK: Random and sample data
extension PSVector {
    static var randomNormalized:PSVector {
        let random = Double.random(in:0...Double.pi*2)
        return PSVector(direction: random, magnitude: 1)
    }
    
    

}
