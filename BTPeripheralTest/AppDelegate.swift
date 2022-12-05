//
//  AppDelegate.swift
//  BTPeripheralTest
//
//  Created by saumyamukul on 12/1/22.
//

import Cocoa
import CoreBluetooth
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let BLEService_UUID = CBUUID(string: "0000180d-0000-1000-8000-00805f9b34fb")
    let BLE_Characteristic_uuid_Tx = CBUUID(string: "0x4567")//(Property = Write without response)
    let BLE_Characteristic_uuid_Rx = CBUUID(string: "00002a37-0000-1000-8000-00805f9b34fb")// (Property = Read/Notify)
    var characteristic: CBMutableCharacteristic? = nil

    var manager: CBPeripheralManager? = nil


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        manager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

// MARK: - CBPeripheralManagerDelegate
extension AppDelegate: CBPeripheralManagerDelegate {
    func getService() -> CBMutableService {
        let service = CBMutableService(type: BLEService_UUID, primary: true)
        characteristic = CBMutableCharacteristic(type: BLE_Characteristic_uuid_Rx, properties: [.read, .write, .notify], value: nil, permissions: [.readable, .writeable])
        service.characteristics = [characteristic!]
        return service
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOff:
            NSLog("BLE Test: Is Powered Off.")
        case .poweredOn:
            // Add GATT service
            peripheral.add(getService())
            peripheral.startAdvertising([CBAdvertisementDataLocalNameKey : "Mac Peripheral Test"])
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [self] timer in
                var theData : UInt8 = 3
                let data = Data(bytes: &theData, count: 1)
                peripheral.updateValue(data, for: characteristic!, onSubscribedCentrals: nil)
            }
        case .unknown: break
        case .resetting: break
        case .unsupported: break
        case .unauthorized: break
        @unknown default:
            NSLog("Unknown peripheral state")
        }
    }
}
