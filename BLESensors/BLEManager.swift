//
//  BLEManager.swift
//  BLESensors
//
//  Created by Alex Yee on 6/10/15.
//  Copyright (c) 2015 Alex Yee. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEManagerDelegate{
    //Delegate function to notify that sensor data received
    func notifyBLEDataReceived(data: [UInt8], sensorName: String)
}
class BLEManager:NSObject {
    var bleDelegate: BLEManagerDelegate?
    var centralManager = CBCentralManager()
    var peripheralManager = CBPeripheralManager()
    var connectedPeripherals = [CBPeripheral]()
    
    override init(){
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
}
//MARK: CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate{
    //Required for delegate
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch centralManager.state {
        case .PoweredOff:
            //Handle if BLE hardware powered off
            break
        case .PoweredOn:
            //Handle if BLE hardware powered on
            self.scanForPeripherals(self)
            break
        case .Resetting:
            //Handle if BLE hardware resetting
            break
        case .Unauthorized:
            //Handle if BLE hardware unauthorized
            break
        case .Unknown:
            //Handle if BLE hardware unknown
            break
        case .Unsupported:
            //Handle if BLE hardware unsupported
            break
        default:
            break
        }
    }
    //Wrapper function to scan for peripherals with narrowed search for Red Bear Labs UUIDs
    func scanForPeripherals(sender:AnyObject){
        centralManager.scanForPeripheralsWithServices([BLEConstants.RBL_SERVICE_UUID], options: nil)
    }
    //Handler to add found peripherals to peripheral array
    func centralManager(central: CBCentralManager!,
        didDiscoverPeripheral peripheral: CBPeripheral!,
        advertisementData: [NSObject : AnyObject]!,
        RSSI: NSNumber!) {
            central.connectPeripheral(peripheral, options: nil)
            self.connectedPeripherals.append(peripheral)
    }
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {}
}
//MARK: CBPeripheralManagerDelegate
extension BLEManager: CBPeripheralManagerDelegate{
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        switch peripheralManager.state {
        case .PoweredOff:
            //Handle if BLE hardware powered off
            break
        case .PoweredOn:
            //Handle if BLE hardware powered on
            break
        case .Resetting:
            //Handle if BLE hardware resetting
            break
        case .Unauthorized:
            //Handle if BLE hardware unauthorized
            break
        case .Unknown:
            //Handle if BLE hardware unknown
            break
        case .Unsupported:
            //Handle if BLE hardware unsupported
            break
        default:
            break
        }
    }
}
//MARK: CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate{
    // Called when new services discovered
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        var service:CBService
        for service in peripheral.services {
            peripheral.discoverCharacteristics(nil, forService: service as! CBService)
        }
    }
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!)
    {
        var characteristic = CBCharacteristic()
        for characteristic in service.characteristics {
            //Use this to continuously notify
            peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
        }
    }
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if characteristic.isNotifying == true {
            peripheral.readValueForCharacteristic(characteristic as CBCharacteristic)
        }
    }
    // Called when characteristic value is updated
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error:NSError!){
        if(characteristic.UUID == BLEConstants.RBL_CHAR_TX_UUID){
            var dataLength = characteristic.value.length
            var data = [UInt8](count: dataLength, repeatedValue: 0x0)
            characteristic.value.getBytes(&data, length: dataLength)
            //Set delegate to notify data received
            bleDelegate?.notifyBLEDataReceived(data, sensorName: peripheral.name)
        }
    }
}