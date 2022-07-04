////
////  Angle.swift
////  Wind
////
////  Created by Labtanza on 6/22/22.
////
//
//import Foundation
//import Numerics
//
////TODO: Should I just extend SwiftUI Angle? Double?
////TODO: Is there a class of "that for which trig functions are defin ed?" <- Numerics
//
//struct PSAngle<ValueType: Real> {
//
//    let value:ValueType
//
//    init(_ vector:(i:ValueType, j:ValueType)){
//        value = atan2(vector.j, vector.i)
//    }
//
//    init(x:Double, y:Double){
//        value = atan2(x, y)
//    }
//
//    init(_ radians:Double){
//        self.value = radians
//    }
//
//    init(degrees:Double) {
//        self.value = degrees.asRadians
//    }
//
//    var degrees:Double {
//        self.value.asDegrees
//    }
//    
//    var radians:Double {
//        self.value
//    }
//
//    var vectorComponents:(i:Double, j:Double) {
//        let i = cos(value)
//        let j = sin(value)
//        return (i, j)
//    }
//}
//
////MARK: Angle Conversions
//extension Real {
//    var asDegrees:Self {
//        (self/180) * .pi
//    }
//    
//    //TODO: possibly should use M_1_PI or is that overkill / not an issue anymore?
//    var asRadians:Self {
//        self * 180 / .pi
//    }
//}
//
//extension Int {
//    var asRadians:Double {
//        Double(self) * 180.0 / Double.pi
//    }
//}
