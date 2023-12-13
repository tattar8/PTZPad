//
//  ViscaPTZController.swift
//  PTZPad
//
//  Created by Taikhoom Attar on 10/9/23.
//

import Foundation
import Network


class ViscaPTZController{
    
    var host: NWEndpoint.Host// = "172.16.2.13"
    var port: NWEndpoint.Port// = 10023
    
    var errorCmdHandler: ((Error) -> Void) = {_ in }
    
    var connection: NWConnection?
    
    //hack, fix later
    var ManagerPresetClosure: (Data)->Void = {_ in}
    
    init(host: String, port: String){
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(port)!
    }
    
    
    
    func connect(){
        connection = NWConnection(host: host, port: port, using: .udp)
        
        connection!.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .preparing:
                NSLog("Host \(self.host)  state: preparing")
            case .ready:
                NSLog("Host \(self.host)  state: ready")
            case .setup:
                NSLog("Host \(self.host)  state: setup")
            case .cancelled:
                NSLog("Host \(self.host)  state: cancelled")
            case .waiting:
                NSLog("Host \(self.host)  state: waiting")
            case .failed:
                NSLog("Host \(self.host)  state: failed")
            default:
                NSLog("Host \(self.host)  state: unknown")
            }
        }
        
        connection!.viabilityUpdateHandler = { (isViable) in
            if (isViable) {
                NSLog("Host \(self.host)  viable")
                //let _ = self.register()
                //let _ = self.receiveMessage(connection: self.connection!, repeated: true, RetClosure: {_ in})
            } else {
                NSLog("Host \(self.host)  not viable")
            }
        }
        
        connection!.betterPathUpdateHandler = { (betterPathAvailable) in
            if (betterPathAvailable) {
                NSLog("Host \(self.host) A better path is availble")
            } else {
                NSLog("Host \(self.host) No better path is available")
            }
        }
        
        connection!.start(queue: .global())
    }
    
    func receiveMessage(connection:NWConnection, repeated:Bool, numberOfTimes:Int = -1, RetClosure:@escaping (Data)->Void){
        connection.receiveMessage { (data, context, isComplete, error) in
            if let myData = data {
                //print("Data received: \(myData as NSData)")
                if (myData.count > 5){
                    //not an ack
                    //This is a bad idea, do not do this!!!
                    //todo fix later
                    
                    if (myData.count == 11 || myData.count == 7){
                        self.ManagerPresetClosure(myData)
                    }
                    RetClosure(myData)
                }
            }
            if (repeated && (numberOfTimes > 0 || numberOfTimes == -1)) {self.receiveMessage(connection: connection, repeated: true, numberOfTimes: numberOfTimes == -1 ? -1 : numberOfTimes - 1, RetClosure: RetClosure)}
        }
    }
    
    func send(_ payload: Data, rcv:Int=0, RetClosure:@escaping (Data)->Void) {
        connection!.send(content: payload, completion: .contentProcessed({ [self] sendError in
            if let error = sendError {
                NSLog("Unable to process and send the data: \(error)")
                errorCmdHandler(error)
            } else {
                NSLog("Data has been sent")
                //if (rcv>0){
                    receiveMessage(connection: connection!, repeated: (rcv > 0), numberOfTimes:rcv, RetClosure: RetClosure)
                //}
            }
            
        }))
    }
    
    func pan (xSpeed:Double, ySpeed: Double){
        let maxSpeedY = 0x18
        let maxSpeedX = 0x14
        let adjSpeedX : UInt8 = UInt8(abs(Double(maxSpeedX) * xSpeed))
        let adjSpeedY : UInt8 = UInt8(abs(Double(maxSpeedY) * ySpeed))
        
        print("Pan: X=\(adjSpeedY), Y=\(adjSpeedX)")
        
        let xSelect : UInt8 = (xSpeed > 0.0) ? 1 : (xSpeed < 0.0) ? 2 : 3
        let ySelect : UInt8 = (ySpeed < 0.0) ? 1 : (ySpeed > 0.0) ? 2 : 3
        
        var cmdBytes:[UInt8] = [0x81, 0x01, 0x06, 0x01, adjSpeedY, adjSpeedX, ySelect, xSelect, 0xff]
        
        send(Data(cmdBytes), RetClosure:{_ in })
        
    }
    
    func zoom(speed:Double){
        let maxSpeed = 7
        
        let adjSpeed : UInt8 = UInt8(abs(Double(maxSpeed) * speed))
        
        let dirSelect = (speed > 0.0) ? 2 : (speed < 0.0) ? 3 : 0
        
        print("Zoom: Dir=\(dirSelect), val=\(adjSpeed)")
        
        
        var cmdBytes:[UInt8] = [0x81, 0x01, 0x04, 0x07, (UInt8(dirSelect) << 4) | adjSpeed, 0xff]
        
        send(Data(cmdBytes), RetClosure:{_ in })
    }
    
    func getPTZPosition(RetClosure: @escaping (Data)->Void){
        var cmdBytes:[UInt8] = [0x81, 0x09, 0x06, 0x12, 0xFF]
        var dataBytes:Data = Data()
        ManagerPresetClosure = RetClosure
        send(Data(cmdBytes), rcv: 1, RetClosure: RetClosure)
    }
    
    func getPTZZoom(RetClosure: @escaping (Data)->Void){
        var cmdBytes:[UInt8] = [0x81, 0x09, 0x04, 0x47, 0xFF]
        var dataBytes:Data = Data()
        ManagerPresetClosure = RetClosure
        send(Data(cmdBytes), rcv: 1, RetClosure: RetClosure)
    }
    
    func recallPTZPositionZoom(posData:Data, zoomData:Data){
        var cmdBytes:[UInt8] = [0x81, 0x01, 0x06, 0x02, 0x18, 0x14] + posData + [0xff]
        send(Data(cmdBytes), RetClosure:{_ in })
        cmdBytes = [0x81, 0x01, 0x04, 0x47] + zoomData + [0xff]
        send(Data(cmdBytes), RetClosure:{_ in })
    }
}
