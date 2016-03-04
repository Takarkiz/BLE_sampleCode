//
//  ViewController.swift
//  bleSample_2
//
//  Created by 澤田昂明 on 2016/03/03.
//  Copyright © 2016年 Takarki. All rights reserved.
//

import CoreBluetooth
import UIKit

class ViewController: UIViewController,CBCentralManagerDelegate {
    
    var centralManager:CBCentralManager!
    //ペリフェラルのプロパティ宣言
    var peripheral:CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //CBCentralManagerの状態が変化した時に呼ばれるメソッド
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("state \(central.state)");
        switch (central.state) {
        case .PoweredOff:
            print("Bluetoothの電源がOff")
        case .PoweredOn:
            print("Bluetoothの電源はOn")
            // BLEデバイスの検出を開始.
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
        case .Resetting:
            print("レスティング状態")
        case .Unauthorized:
            print("非認証状態")
        case .Unknown:
            print("不明")
        case .Unsupported:
            print("非対応")
        }
    }
    
    /*
    BLEデバイスが検出された際に呼び出される.
    */
    func centralManager(central: CBCentralManager,didDiscoverPeripheral peripheral: CBPeripheral,advertisementData: [String:AnyObject],RSSI: NSNumber){
        print("pheripheral.name: \(peripheral.name)")
        print("advertisementData:\(advertisementData)")
        print("RSSI: \(RSSI)")
        print("peripheral.identifier.UUIDString: \(peripheral.identifier.UUIDString)")
        
        var name: NSString? = advertisementData["kCBAdvDataLocalName"] as? NSString
        if (name == nil) {
            name = "no name";
        }
        
        self.peripheral = peripheral
        
        //BLEデバイスが検出された時にペリフェラルの接続を開始する
        self.centralManager.connectPeripheral(self.peripheral, options:nil)

        
     }
    
    //ペリフェラルの接続が成功すると呼ばれる
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("接続成功!")
    }
    //ペリフェラルの接続が失敗すると呼ばれる
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("接続失敗...")
    }
    
    @IBAction func scanstart(){
        //CBCentralManagerを初期化する
        centralManager = CBCentralManager(delegate:self,queue: nil, options:nil)
        
    }



}

