import Foundation
import MobileVLCKit
import SwiftUI

struct VlcPlayerRepresentable: UIViewRepresentable{ //MARK: Transform from a UIView into swiftUI compatible
    var url: URL
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VlcPlayerRepresentable>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero, url: url)
    }}

class PlayerUIView: UIView, VLCMediaPlayerDelegate,ObservableObject{
    let mediaPlayer : VLCMediaPlayer = VLCMediaPlayer()// You can also add options in here
    init(frame: CGRect, url: URL) {
        super.init(frame: UIScreen.screens[0].bounds)
        let media = VLCMedia(url: url)
        
        media.addOptions([// Add options here
            "network-caching": 0,
            "--rtsp-frame-buffer-size":100,
            "--vout": "ios",
            "--glconv" : "glconv_cvpx",
            "--rtsp-caching=": 0,
            "--tcp-caching=": 0,
            "--realrtsp-caching=": 0,
            "--h264-fps": 20.0,
            "--mms-timeout": 60000
                         ])
        
        mediaPlayer.media = media
        mediaPlayer.delegate = self
        mediaPlayer.drawable = self
        mediaPlayer.audio?.isMuted = true
        
        mediaPlayer.videoAspectRatio = UnsafeMutablePointer<Int8>(mutating: ("16:9" as NSString).utf8String)
        mediaPlayer.play()}
    
    func checkConnection() -> Bool{
        let isPlaying: Bool = mediaPlayer.isPlaying
        return isPlaying
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct StreamsTab: View {
    var body: some View {
        return VStack{
            Text("stream")
            VlcPlayerRepresentable(url: URL(string: "rtsp://zephyr.rtsp.stream/movie?streamKey=55b74d674fbb01358f938ae93c1b16ff")!)
        }
    }}
