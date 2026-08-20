import SwiftUI

struct GameView: View {
    @EnvironmentObject var emulatorManager: EmulatorManager
    @State private var displayLink: CADisplayLink?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Game Screen
                ScreenView()
                    .environmentObject(emulatorManager)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(256/240, contentMode: .fit)
                    .padding()
                
                Spacer()
                
                // Controller
                ControllerView()
                    .environmentObject(emulatorManager)
                    .padding()
            }
            .background(Color.black)
            
            // Header
            VStack {
                HStack {
                    Button(action: { emulatorManager.unloadGame() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    Text(emulatorManager.currentGame ?? "NES World")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "pause.fill")
                            .padding()
                    }
                }
                .background(Color(.systemGray6))
                
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

struct ScreenView: View {
    @EnvironmentObject var emulatorManager: EmulatorManager
    @State private var uiImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.black
            
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading...")
                        .foregroundColor(.white)
                }
            }
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            updateFrame()
        }
    }
    
    private func updateFrame() {
        if let frameBuffer = emulatorManager.getFrameBuffer() {
            uiImage = createImage(from: frameBuffer)
        }
    }
    
    private func createImage(from buffer: [UInt8]) -> UIImage? {
        let width = 256
        let height = 240
        
        var rgbData = [UInt8]()
        for i in stride(from: 0, to: buffer.count, by: 4) {
            if i + 3 < buffer.count {
                rgbData.append(buffer[i])
                rgbData.append(buffer[i + 1])
                rgbData.append(buffer[i + 2])
            }
        }
        
        let bitsPerComponent = 8
        let bitsPerPixel = 24
        let bytesPerRow = width * 3
        
        guard let dataProvider = CGDataProvider(data: NSData(bytes: rgbData, length: rgbData.count)) else {
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: .byteOrderDefault,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    GameView()
        .environmentObject(EmulatorManager())
}