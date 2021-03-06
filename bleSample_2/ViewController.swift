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
    
    @IBOutlet var label:UILabel!
    
    let cbserviceUUID = "BD011F22-7D3C-0DB6-E441-55873D44EF40"
    let charactaUUID = "2A750D7D-BD9A-928F-B744-7D5A70CEF1F9"
    
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
        
        //var serviceUUIDs: [CBUUID] = [CBUUID.UUIDWithString(kServiceUUID)]
        //self.centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: nil)

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
        
        if peripheral.name == "BLESerial2"{
            
            print("pheripheral.name: \(peripheral.name)")
            print("advertisementData:\(advertisementData)")
            print("RSSI: \(RSSI)")
            print("peripheral.identifier.UUIDString: \(peripheral.identifier.UUIDString)")
            
            var name: NSString? = advertisementData["kCBAdvDataLocalName"] as? NSString
            if (name == nil) {
                name = "no name";
            }
            
            self.peripheral = peripheral
            
            //peripheral.name はStringっぽいのでこのような条件分岐ができる
            //ここでは欲しいシリアルのペリフェラルだけを取得
            
            //BLEデバイスが検出された時にペリフェラルの接続を開始する
            self.centralManager.connectPeripheral(self.peripheral, options:nil)
            
            
        }
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
        
        
        for obj in characteristics{
            if let characteristic = obj as? CBCharacteristic{
                
                //Read専用のキャラクタリスティックに限定して読み出す
                /*現段階でこのRead専用のキャラクタリスティックが読み出せない．
                Arduino側の設定をしていないからか*/
                //if characteristic.UUID == charactaUUID{
                    
                    peripheral.readValueForCharacteristic(characteristic)
                //}
            }
        }
    }
    
    //キャラクタリスティックが読み出された時に呼ばれるメソッド
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("読み出し成功! service uuid:\(characteristic.service.UUID), characteristic uuid:\(characteristic.UUID), vallue:\(characteristic.value)")
        
//        if characteristic.value != nil{
//            var val = characteristic.value as! String
//            label.text = val
//        }
        if characteristic.UUID.isEqual(CBUUID(string:"2A750D7D-BD9A-928F-B744-7D5A70CEF1F9")){
            
            var byte:CUnsignedChar = 0
            
            //1バイト取り出す
            characteristic.value?.getBytes(&byte, length:1)
            
            print(byte)
            
        }
    }
    
    



}

