//
//  PSVectorTests.swift
//  
//
//  Created by Labtanza on 7/8/22.
//

import XCTest
@testable import ParticleSystem

final class PSVectorTests: XCTestCase {
    typealias V = PSVector
    //static let π = Double.pi
    
    func goodEnoughEqual(_ a: PSVector.Basic, _ b: PSVector.Basic) -> Bool {
        return abs(a - b) < 0.000001  //Double.ulpOfOne is too precise
   }
    func goodEnoughEqual(d1: Double, d2: Double) -> Bool {
        return abs(d1 - d2) < 0.00001  //Double.ulpOfOne is too precise
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
    
    func testComponentInVsDirectionDegrees() {
        for testPair in Self.componentTestVectorSet {
            var testPassed = false
            testPassed = goodEnoughEqual(d1:testPair.input.theta, d2:testPair.vector.asAngle.degrees)
            
            XCTAssertTrue((testPassed), "\(testPair.input.theta) is not the same as \(testPair.vector.asAngle.degrees) for pair (\(testPair.input.adjacent), \(testPair.input.adjacent))")
        }
    }
    
    //direction, magnitude initializer should result in a co-terminal value.
    func testAngleInVsDirection() {
        for testPair in Self.angleTestVectorSet {
            var testPassed = false
            
            if testPair.angle.magnitude <= V.tau {
                if testPair.angle == testPair.vector.angleInRadians {
                    testPassed = true
                } else if goodEnoughEqual((testPair.angle.magnitude + testPair.vector.angleInRadians.magnitude), V.tau) {
                    testPassed = true
                }
            } else {
                let reducedAngle = testPair.angle.truncatingRemainder(dividingBy: V.tau)
                print("reduced angled for \(testPair.angle) is \(reducedAngle)")
                if goodEnoughEqual(reducedAngle, testPair.vector.angleInRadians) {
                    testPassed = true
                } else if goodEnoughEqual((reducedAngle.magnitude + testPair.vector.angleInRadians.magnitude), V.tau) {
                    testPassed = true
                }
            }

            XCTAssertTrue((testPassed), "\(testPair.angle) is not coterminal to \(testPair.vector.angleInRadians)")
        }
    }

}
