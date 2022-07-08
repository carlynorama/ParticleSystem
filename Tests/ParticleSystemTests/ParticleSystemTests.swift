import XCTest
@testable import ParticleSystem

final class ParticleSystemTests: XCTestCase {
    //var particleSystem:ParticleSystem
//    var sharedManager:ParticleSystem.ParticleManager
//    var psVector:PSVector
//
    override func setUpWithError() throws {
//        sharedManager = ParticleSystem.ParticleManager()
//        psVector = PSVector(0.0, 0.0)
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ParticleSystem().text, "Hello, World!")
    }
}
