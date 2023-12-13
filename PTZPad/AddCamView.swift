//
//  AddCamView.swift
//  PTZPad
//
//  Created by Taikhoom Attar on 10/5/23.
//

import SwiftUI

struct AddCamView: View {
    @Environment(\.dismiss) var dismiss
    let nMixers: Binding<Int> = Binding<Int>(get: {
        return PTZManager.shared.ptzCams.count
    }, set: {_ in
        
    })
    @State private var showingSheet = false
    var body: some View {
        VStack{
            Form{
                Section("Cameras"){
                    List(){
                        ForEach(PTZManager.shared.ptzCams, id: \.self.id){profile in
                            HStack{
                                Text(profile.name)
                                Spacer()
                                
                            }
                        }
#if os(iOS)
                        .onDelete(perform: {indices in
                            print("Attempt to delete \(indices.first!)")
                            PTZManager.shared.deleteCam(id: PTZManager.shared.ptzCams[indices.first!].id)
                        })
#endif
                    }
                }
#if os(iOS)
                Section{
                    Button("Add..."){
                        showingSheet.toggle()
                    }
                }
#endif
            }.sheet(isPresented: $showingSheet) {
#if os(iOS)
                CamFormView()
                //Text("todo")
#endif
            }
        }
        
        
    }
}

struct CamFormView: View{
    @Environment(\.dismiss) var dismiss
    @State var viscaAddress: String = ""
    @State var viscaPort: String = ""
    @State var rtspURL: String = ""
    @State var rtspURL2: URL?
    @State var name: String = ""
    
    var body: some View{
        Form{
            Section(header: Text("PTZ Control")){
                TextField(text: $name, prompt: Text("Name (Required)"), label: {Text("Name (Required)")})
                TextField(text: $viscaAddress, prompt: Text("VISCA Control IP Address (Required)"), label: {Text("IP Address (Required)")})
                TextField(text: $viscaPort, prompt: Text("VISCA Control Port (1259)"), label: {Text("VISCA Control Port (1259)")})
            }
            Section(header: Text("RTSP Preview")){
                TextField(text: $rtspURL, prompt: Text("RTSP Feed URL (optional)"), label: {Text("RTSP Feed URL (optional)")})
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Section{
                Button("Save"){
                    //validate inputs
                    
                    if (viscaPort == ""){
                        viscaPort = "1259"
                    }
                    
                    guard ((1...65535).contains(Int(viscaPort) ?? 0)) else{
                        print("Invalid port")
                        return
                    }
                    
                    if (viscaAddress.isEmpty){
                        print("No address")
                        return
                    }
                    
                    if (name.isEmpty){
                        print("No name")
                        return
                    }
                    
                    PTZManager.shared.addNewCam(viscaAddr: viscaAddress, viscaPort: viscaPort, rtspURL: rtspURL, name: name)
                    dismiss()
                }.frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

extension View {
    func onTapGestureForced(count: Int = 1, perform action: @escaping () -> Void) -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture(count:count, perform:action)
    }
}

struct AddCamView_Previews: PreviewProvider {
    static var previews: some View {
        AddCamView()
    }
}
