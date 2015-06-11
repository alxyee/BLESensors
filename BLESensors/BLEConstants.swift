//
//  BLEConstants.swift
//  BLESensors
//
//  Created by Alex Yee on 6/10/15.
//  Copyright (c) 2015 Alex Yee. All rights reserved.
//

import CoreBluetooth.CBUUID
struct BLEConstants{
    static let RBL_SERVICE_UUID = CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")
    static let RBL_CHAR_TX_UUID = CBUUID(string: "713D0002-503E-4C75-BA94-3148F18D941E")
    static let RBL_CHAR_RX_UUID = CBUUID(string: "713D0003-503E-4C75-BA94-3148F18D941E")
}