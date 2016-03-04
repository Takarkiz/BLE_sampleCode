//
//  ViewController.swift
//  bleSample_2
//
//  Created by 澤田昂明 on 2016/03/03.
//  Copyright © 2016年 Takarki. All rights reserved.
//

import CoreBluetooth
import UIKit

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    
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
    
    
    @IBAction func scanstart(){
        //CBCentralManagerを初期化する
        centralManager = CBCentralManager(delegate:self,queue: nil, options:nil)
        
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
        
        /*ペリフェラルの接続が成功時,
        サービス探索結果を受け取るためにデリゲートをセット*/
        peripheral.delegate = self
        
        //サービス探索開始(nilを渡すことで全てのサービスが探索対象になる)
        peripheral.discoverServices(nil)
        print("サービスの探索を開始しました．")
    }
    //ペリフェラルの接続が失敗すると呼ばれる
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("接続失敗...")
    }
    
    //サービスが見つかった時に呼ばれるメソッド
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        let services:NSArray = peripheral.services!
        print("\(services.count)個のサービスを発見 \(services)")
        
        for obj in services{
            if let service = obj as? CBService{
                
                //キャラクタリスティックの探索を開始する
                peripheral.discoverCharacteristics(nil, forService: service)

            }
        }
        
    }
    
    //キャラクタリスティックが見つかった時に呼ばれるメソッド
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        let characteristics:NSArray = service.characteristics!
        print("\(characteristics.count)個のキャラクタリスティックを発見! \(characteristics)")
    }
    
    



}

