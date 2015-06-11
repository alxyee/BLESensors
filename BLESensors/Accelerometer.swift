//
//  Accelerometer.swift
//  BLESensors
//
//  Created by Alex Yee on 6/10/15.
//  Copyright (c) 2015 Alex Yee. All rights reserved.
//

import Foundation

class Accelerometer:NSObject{
    var timeStamp = [String]()
    var accelX = [Double]()
    var accelY = [Double]()
    var accelZ = [Double]()
    
    func storeXVal(valToStore:Double){
        accelX.append(valToStore)
    }
    func storeYVal(valToStore:Double){
        accelY.append(valToStore)
    }
    func storeZVal(valToStore:Double){
        accelZ.append(valToStore)
    }
}
