//
//  ContentView.swift
//  PTZPad
//
//  Created by Taikhoom Attar on 10/9/23.
//

import SwiftUI

struct ContentView: View {
    var test = GamepadControl()
    @State private var showingSheet = false
    
    @ObservedObject var cams = PTZManager.shared
    
    let columns = [GridItem(.flexible())]
    
    var body: some View {
        NavigationView{
            if (cams.ptzCams.count != 0){
                HStack {
                    ForEach(cams.ptzCams,id: \.self.id){ cam in
                        ZStack(alignment: .bottom){
                            Rectangle().fill(.black)
                            VlcPlayerRepresentable(url: URL(string:cam.rtspURL)!)
                                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .topLeading)
                                .onTapGesture {
                                    print("selected \(cam.id)")
                                    cams.selectedCam = cam.id
                                }
                            Text(cam.name).background(
                                
                                RoundedRectangle(

                                    cornerRadius: 5,
                                    style: .continuous
                                ).fill(.white).opacity(0.5)).offset(x:0, y:-10)
                                
                        }.border(cams.selectedCam != cam.id ? .clear : .green, width: 10)
                    }
                }
                .padding()
                .toolbar {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "gear.circle")//.foregroundColor(.white)
                    }
                    Button{
                        test.showVirtualController()
                    } label: {
                        Image(systemName: "gamecontroller")
                    }
                }
            }
            else{
                Text("No cameras have been added.").italic()
                    .toolbar {
                        Button {
                            showingSheet.toggle()
                        } label: {
                            Image(systemName: "gear.circle")//.foregroundColor(.white)
                        }
                    }
            }
        }
        .sheet(isPresented: $showingSheet) {
            AddCamView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
