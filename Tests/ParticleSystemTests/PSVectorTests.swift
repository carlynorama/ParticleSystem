//
//  PSVectorTests.swift
//  
//
//  Created by Labtanza on 7/8/22.
//

import XCTest
@testable import ParticleSystem

//TODO: distance functions
//TODO: Math functions
//TODO: Transformations

//TODO: How much does Pair and polarValue being calculated slow the math down
//test against hard code at init and have setters that update each other?



class PSVectorTests: XCTestCase {
    typealias V = PSVector
    
    public func close(_ a: any BinaryFloatingPoint, _ b: any BinaryFloatingPoint) -> Bool {
        let l = Double(a)
        let r = Double(b)
        return abs(l - r) < 0.00001
    }
    
    //MARK: Generating Test Data
    static let angleTestVectorSet = generateAngleTestVectors()
    
    static func generateAngleTestVectors() -> [(angle:PSVector.Basic, vector:V)] {
        var vectors = V.commonAngles.map { angle in (angle:angle, vector:V(direction: angle, magnitude: 1))}
        vectors.append(contentsOf: V.commonAngles.map { angle in (angle:(-1.0 * angle), vector:V(direction: (-1.0 * angle), magnitude: 1))})
        return vectors
    }
    
    static let componentTestVectorSet = generateComponentTestVectors()
    
    static func generateComponentTestVectors() -> [(input:(adjacent:V.Basic, opposite:V.Basic, theta:Double), vector:V)] {
        
        let testData = testTriangles.map { triangle in
            let vector = V(triangle.adjacent, triangle.opposite)
            return (input:triangle, vector:vector)
        }
        return testData
    }
    
    static let testTriangles:[(adjacent:V.Basic, opposite:V.Basic, theta:Double)] = [
        (4.0, 3.0, 36.8698976),
        (5.0, 5.0, 45.0),
        (3.0, 4.0, 53.13010235),
        (-5.0, 5.0, 135.0),
        (-7.0, 7.0, 135.0),
        (-1.0, 1.0, 135.0),
        (1.0, -1.0, -45.0),
        (-3.5, -3.5, -135)
    ]
    
    
    //MARK: Testing initializer data against outputs
    
    //use component created vector set and test their output angles
    //in degress against the expected angle in degrees from the
    //sample data.
    func testComponentInVsDirectionDegrees() {
        for testPair in Self.componentTestVectorSet {
            var testPassed = false
            testPassed = close(testPair.input.theta, testPair.vector.asAngle.degrees)
            
            XCTAssertTrue((testPassed), "\(testPair.input.theta) is not the same as \(testPair.vector.asAngle.degrees) for pair (\(testPair.input.adjacent), \(testPair.input.adjacent))")
        }
    }
    
    //use direction, magnitude created vector set and test
    //that the output from .angleInRadians is co-terminal with
    //the original input angle.
    func testAngleInVsDirection() {
        for testPair in Self.angleTestVectorSet {
            var testPassed = false
            
            if testPair.angle.magnitude <= V.tau {
                if testPair.angle == testPair.vector.angleInRadians {
                    testPassed = true
                } else if close((testPair.angle.magnitude + testPair.vector.angleInRadians.magnitude), V.tau) {
                    testPassed = true
                }
            } else {
                let reducedAngle = testPair.angle.truncatingRemainder(dividingBy: V.tau)
                print("reduced angled for \(testPair.angle) is \(reducedAngle)")
                if close(reducedAngle, testPair.vector.angleInRadians) {
                    testPassed = true
                } else if close((reducedAngle.magnitude + testPair.vector.angleInRadians.magnitude), V.tau) {
                    testPassed = true
                }
            }
            
            XCTAssertTrue((testPassed), "\(testPair.angle) is not coterminal to \(testPair.vector.angleInRadians)")
        }
    }
    
    //MARK: Testing polarValues agains toPolar
    
    //magnitude calculated using pythag should be same as returned value. 
    func testMagnitudeAgainstComponents() {
        for testPair in Self.componentTestVectorSet {
            let h = sqrt(pow(testPair.input.opposite, 2) + pow(testPair.input.adjacent, 2))
            
            XCTAssertTrue(h == V.Basic(testPair.vector.polarComponets.magnitude), "sqrt(a^2 + b^2) \(h) does not equal vector.magnitude \(testPair.vector.polarComponets.magnitude)")
        }
    }
    
    //Use 4, 3, 5 triangle to test the static .toPolar function
    func testToPolar() {
        var testPassed = false
        let result = V.toPolar(x: 4.0, y: 3.0)
        let expectedTheta = atan2(3.0, 4.0)
        let expectedH = 5.0
        if close(result.magnitude, expectedH) && close(result.direction, expectedTheta) {
            testPassed = true
        }
        XCTAssertTrue((testPassed), "V.toPolar broke the 3, 4, 5 triangle with mag\(result.magnitude), dir\(result.direction)")
    }
    
    //use the component created vector set to make sure the  static .fromPolar
    //function and instance.polarComponets have matching results.
    //(Also makes sure the components are as expected.)
    func testPolarCoordVsFromPolar() {
        for testPair in Self.componentTestVectorSet {
            var testPassed = false
            let polar1 = testPair.vector.polarComponets
            let polar2 = V.toPolar(x: testPair.input.adjacent, y: testPair.input.opposite)
            
            XCTAssertTrue(testPair.vector.x == Double(testPair.input.adjacent), "components dont match for X: \(testPair.vector.x) =/= \(testPair.input.adjacent)")
            XCTAssertTrue(testPair.vector.y == Double(testPair.input.opposite), "components dont match for Y: \(testPair.vector.y) =/= \(testPair.input.adjacent)")
            
            if close(polar1.direction, polar2.direction) && close(polar1.magnitude, polar2.magnitude) {
                testPassed = true
            }
            
            XCTAssertTrue((testPassed), "[\(testPair.input.adjacent), \(testPair.input.opposite)] vector.polarValues \(polar1) is not similar enough to PSVector.toPolar() \(polar2) from \(testPair.vector.vectorPair)")
        }
    }
    
    //MARK: Math checks
    
    //            let dx = particle.startVelocity.x * interval
    //            let dy = particle.startVelocity.y * interval
    //            let position = (x: particle.startPosistion.x + dx, y: particle.startPosistion.y + dy)

}
