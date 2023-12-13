//
//  PTZControl.swift
//  PTZPad
//
//  Created by Taikhoom Attar on 10/10/23.
//

import Foundation

class PTZControl{
    
    static let shared = PTZControl()
    let mgr = PTZManager.shared
    
    var cams: [UUID:ViscaPTZController] = [:]
    
    init(){
        populate()
    }
    
    func populate(){
        for cam in mgr.ptzCams{
            cams[cam.id] = ViscaPTZController(host: cam.viscaAddr, port: cam.viscaPort)
            cams[cam.id]!.connect()
        }
    }
    
    func test(){
        print("Hello")
    }
    
    func panTilt(camID:UUID, speedX:Double, speedY:Double){
        cams[camID]?.pan(xSpeed: speedX, ySpeed: speedY)
    }
    
    func zoom(camID:UUID, speed:Double){
        cams[camID]?.zoom(speed: speed)
    }
    
    func getPos(camID:UUID, RetClosure: @escaping (Data)->Void){
        cams[camID]?.getPTZPosition(RetClosure: RetClosure)
    }
    
    func getZoom(camID:UUID, RetClosure: @escaping (Data)->Void){
        cams[camID]?.getPTZZoom(RetClosure: RetClosure)
    }
    
    func recallPTZ(camID:UUID, ptData:Data, zData:Data){
        cams[camID]?.recallPTZPositionZoom(posData: ptData, zoomData: zData)
    }
}
