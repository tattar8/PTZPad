//
//  GamepadControl.swift
//  PTZPad
//
//  Created by Taikhoom Attar on 10/9/23.
//

import Foundation
import GameController

class GamepadControl{
    
    var virtualController: GCVirtualController?
    var cams = PTZManager.shared
    var buttonPressTimer:Double = 0
    init(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil){
            (note) in
            guard let _controller = note.object as? GCController else{
                return
            }
            
            let buttonA : GCControllerButtonInput = _controller.physicalInputProfile[GCInputButtonA] as! GCControllerButtonInput
            buttonA.valueChangedHandler = {(_,_,pressed) in
                print("A handler: \(pressed)")
                if (pressed){
                    self.buttonPressTimer = Date().timeIntervalSince1970
                }
                else{
                    
                    if (Date().timeIntervalSince1970 - self.buttonPressTimer > 1.0){
                        //long press
                        print("A long press")
                        self.cams.setCamPreset(btn: PTZManager.ButtonMapping.A)
                    }
                    else{
                        self.cams.recallCamPreset(btn: PTZManager.ButtonMapping.A)
                    }
                }
            }
            
            let buttonL : GCControllerButtonInput = _controller.physicalInputProfile[GCInputLeftShoulder] as! GCControllerButtonInput
            buttonL.valueChangedHandler = {(_,_,pressed) in
                print("L handler: \(pressed)")
                if (pressed){
                    //Move selection to the left
                    var newIndex = PTZManager.shared.ptzCams.firstIndex(where: {$0.id == PTZManager.shared.selectedCam})! - 1
                    if (newIndex < 0){
                        newIndex = 0
                    }
                    PTZManager.shared.selectedCam = PTZManager.shared.ptzCams[newIndex].id
                }
            }
            
            let buttonR : GCControllerButtonInput = _controller.physicalInputProfile[GCInputRightShoulder] as! GCControllerButtonInput
            buttonR.valueChangedHandler = {(_,_,pressed) in
                print("R handler: \(pressed)")
                if (pressed){
                    var newIndex = PTZManager.shared.ptzCams.firstIndex(where: {$0.id == PTZManager.shared.selectedCam})! + 1
                    if (newIndex >= PTZManager.shared.ptzCams.count){
                        newIndex = PTZManager.shared.ptzCams.count - 1
                    }
                    PTZManager.shared.selectedCam = PTZManager.shared.ptzCams[newIndex].id
                }
            }
            
            let buttonZR : GCControllerButtonInput = _controller.physicalInputProfile[GCInputRightTrigger] as! GCControllerButtonInput
            buttonZR.valueChangedHandler = {(_,val,pressed) in
                print("ZR handler: \(pressed)")
                PTZControl.shared.zoom(camID:self.cams.selectedCam, speed: Double(val))
            }
            
            let buttonZL : GCControllerButtonInput = _controller.physicalInputProfile[GCInputLeftTrigger] as! GCControllerButtonInput
            buttonZL.valueChangedHandler = {(_,val,pressed) in
                print("ZL handler: \(pressed)")
                PTZControl.shared.zoom(camID:self.cams.selectedCam, speed: Double(-1 * val))
            }
            
            let buttonB : GCControllerButtonInput = _controller.physicalInputProfile[GCInputButtonB] as! GCControllerButtonInput
            buttonB
                .valueChangedHandler = {(_,_,pressed) in
                print("B handler: \(pressed)")
                if (pressed){
                    self.buttonPressTimer = Date().timeIntervalSince1970
                }
                else{
                    
                    if (Date().timeIntervalSince1970 - self.buttonPressTimer > 1.0){
                        //long press
                        print("B long press")
                        self.cams.setCamPreset(btn: PTZManager.ButtonMapping.B)
                    }
                    else{
                        self.cams.recallCamPreset(btn: PTZManager.ButtonMapping.B)
                    }
                }
            }
            
            let buttonX : GCControllerButtonInput = _controller.physicalInputProfile[GCInputButtonX] as! GCControllerButtonInput
            buttonX.valueChangedHandler = {(_,_,pressed) in
                print("X handler: \(pressed)")
                if (pressed){
                    self.buttonPressTimer = Date().timeIntervalSince1970
                }
                else{
                    
                    if (Date().timeIntervalSince1970 - self.buttonPressTimer > 1.0){
                        //long press
                        print("X long press")
                        self.cams.setCamPreset(btn: PTZManager.ButtonMapping.X)
                    }
                    else{
                        self.cams.recallCamPreset(btn: PTZManager.ButtonMapping.X)
                    }
                }
            }
            
            let buttonY : GCControllerButtonInput = _controller.physicalInputProfile[GCInputButtonY] as! GCControllerButtonInput
            buttonY.valueChangedHandler = {(_,_,pressed) in
                print("Y handler: \(pressed)")
                if (pressed){
                    self.buttonPressTimer = Date().timeIntervalSince1970
                }
                else{
                    
                    if (Date().timeIntervalSince1970 - self.buttonPressTimer > 1.0){
                        //long press
                        print("Y long press")
                        self.cams.setCamPreset(btn: PTZManager.ButtonMapping.Y)
                    }
                    else{
                        self.cams.recallCamPreset(btn: PTZManager.ButtonMapping.Y)
                    }
                }
            }
            
            let lStick: GCControllerDirectionPad = _controller.physicalInputProfile[GCInputLeftThumbstick] as! GCControllerDirectionPad
            lStick.valueChangedHandler = {(_,yVal,xVal) in
                //print("LStick handler, \(xVal), \(yVal)")
                
                PTZControl.shared.panTilt(camID:self.cams.selectedCam, speedX: Double(xVal), speedY: Double(yVal))
            }
            
            let rStick: GCControllerDirectionPad = _controller.physicalInputProfile[GCInputRightThumbstick] as! GCControllerDirectionPad
            rStick.valueChangedHandler = {(_,yVal,xVal) in
                //print("RStick handler, \(xVal), \(yVal)")
                PTZControl.shared.panTilt(camID:self.cams.selectedCam, speedX: Double(xVal), speedY: Double(yVal))
                //PTZControl.shared.zoom(camID:self.cams.selectedCam, speed: Double(xVal))
            }
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil){
            (note) in
            print("controller disconnected")
        }
        
    }
    func showVirtualController(){
        // Creating an on-screen controller

        let virtualConfiguration = GCVirtualController.Configuration()

        virtualConfiguration.elements = [
                                         GCInputLeftThumbstick,
                                         GCInputLeftThumbstick,
                                         GCInputRightThumbstick,
                                         GCInputButtonB,
                                         GCInputRightShoulder,
                                         GCInputLeftShoulder,
                                         GCInputLeftTrigger,
                                         GCInputRightTrigger,
                                         GCInputButtonA,
                                         GCInputButtonX,
                                         GCInputButtonY
                                        ]

        virtualController = GCVirtualController(configuration: virtualConfiguration)

        virtualController!.connect()
        
    }
    
}
