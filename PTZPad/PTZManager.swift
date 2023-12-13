//
//  PTZManager.swift
//  PTZPad
//
//  Created by Taikhoom Attar on 10/10/23.
//

import Foundation

class PTZManager : ObservableObject{
    enum ButtonMapping:Int{
        case A
        case B
        case X
        case Y
    }
    
    struct PTZCam: Identifiable, Codable{
        var name : String
        var viscaAddr : String
        var viscaPort : String
        var rtspURL: String
        var id = UUID()
        var zoomPresets: [Data]
        var panPresets: [Data]
    }
    
    @Published var ptzCams: [PTZCam]
    @Published var selectedCam : UUID
    
    static let shared = PTZManager()
    
    init(){
        //ptzCams = UserDefaults.standard.object(forKey: "PTZCams") as? [PTZManager.PTZCam] ?? []
        if
            let data = UserDefaults.standard.value(forKey: "PTZCamsJson") as? Data,
            let camsDecoded = try? JSONDecoder().decode([PTZCam].self, from: data) {
            print(camsDecoded)
            ptzCams = camsDecoded
            selectedCam = camsDecoded[0].id
        }
        else{
            ptzCams = []
            selectedCam = UUID()
        }
    }
    
    func addNewCam(viscaAddr: String, viscaPort: String, rtspURL: String, name: String){
        let newCam: PTZCam = PTZCam(name: name, viscaAddr: viscaAddr, viscaPort: viscaPort, rtspURL: rtspURL, zoomPresets: [Data](repeating: Data(), count: 4), panPresets: [Data](repeating: Data(), count: 4))
        
        ptzCams.append(newCam)
        
        if let data = try? JSONEncoder().encode(ptzCams) {
            UserDefaults.standard.set(data, forKey: "PTZCamsJson")
        }
        
        PTZControl.shared.populate()
        
        
    }
    
    func deleteCam(id: UUID){
        if let toDelete = ptzCams.enumerated().first(where: {$0.element.id == id}){
            if (toDelete.element.id == selectedCam){
                selectedCam = UUID()
            }
            ptzCams.remove(at: toDelete.offset)
            
            if let data = try? JSONEncoder().encode(ptzCams) {
                UserDefaults.standard.set(data, forKey: "PTZCamsJson")
            }
            
            PTZControl.shared.populate()
        }
    }
    
    func setCamPreset(btn:ButtonMapping){
        //var dataOut: Data = Data()
        //let semaphore = DispatchSemaphore(value: 1)
        PTZControl.shared.getPos(camID: selectedCam, RetClosure: {data in
            //dataOut = data;
            let sel = self.ptzCams.enumerated().first(where: {$0.element.id == self.selectedCam})
            if (data.count == 11){
                //hack, should fix but no time right now
                self.ptzCams[sel!.offset].panPresets[btn.rawValue] = data[2...9]
                print("Pos saved as \(data[2...9])")
                
                if let data = try? JSONEncoder().encode(self.ptzCams) {
                    UserDefaults.standard.set(data, forKey: "PTZCamsJson")
                }
            }
            else if (data.count == 7){
                self.ptzCams[sel!.offset].zoomPresets[btn.rawValue] = data[2...5]
                print("Zoom saved as \(data[2...5])")
                
                if let data = try? JSONEncoder().encode(self.ptzCams) {
                    UserDefaults.standard.set(data, forKey: "PTZCamsJson")
                }
            }
            
            
            PTZControl.shared.getZoom(camID: self.selectedCam, RetClosure: {data in
                //dataOut = data;
                let sel = self.ptzCams.enumerated().first(where: {$0.element.id == self.selectedCam})
                self.ptzCams[sel!.offset].zoomPresets[btn.rawValue] = data[2...5]
                print("Zoom saved as \(data[2...5])")
                
                if let data = try? JSONEncoder().encode(self.ptzCams) {
                    UserDefaults.standard.set(data, forKey: "PTZCamsJson")
                }
                
                
            })
        })
        
    }
    
    func recallCamPreset(btn:ButtonMapping){
        let sel = self.ptzCams.enumerated().first(where: {$0.element.id == self.selectedCam})
        PTZControl.shared.recallPTZ(camID: selectedCam, ptData: ptzCams[sel!.offset].panPresets[btn.rawValue], zData: ptzCams[sel!.offset].zoomPresets[btn.rawValue])
    }
    
}
