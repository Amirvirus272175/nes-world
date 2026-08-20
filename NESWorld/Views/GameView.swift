import SwiftUI

struct GameView: View {
    @EnvironmentObject var emulatorManager: EmulatorManager
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        ZStack {
            // Retro TV background
            VStack(spacing: 0) {
                // TV bezel top
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("NES WORLD")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("PLAYING")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.3, green: 0.3, blue: 0.35))
                    
                    // Game screen with scanlines effect
                    ZStack {
                        // Screen background
                        Color.black
                        
                        ScreenView()
                            .environmentObject(emulatorManager)
                        
                        // Scanlines effect
                        Canvas { context in
                            let lineHeight: CGFloat = 2
                            var y: CGFloat = 0
                            
                            while y < 500 {
                                var path = Path()
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: 1000, y: y))
                                
                                context.stroke(
                                    path,
                                    with: .color(Color.black.opacity(0.15)),
                                    lineWidth: lineHeight
                                )
                                y += lineHeight * 2
                            }
                        }
                        .ignoresSafeArea()
                        
                        // Screen glare/reflection
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.05),
                                Color.clear,
                                Color.black.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .frame(height: 320)
                    .cornerRadius(8)
                    .padding(16)
                    .background(Color(red: 0.15, green: 0.15, blue: 0.2))
                }
                .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
                
                // Controller area
                VStack {
                    NESControllerView()
                        .environmentObject(emulatorManager)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(red: 0.2, green: 0.2, blue: 0.25))
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.15, green: 0.15, blue: 0.18),
                        Color(red: 0.1, green: 0.1, blue: 0.12)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .ignoresSafeArea()
            
            // Floating menu button
            VStack {
                HStack {
                    Button(action: { emulatorManager.unloadGame() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "power")
                                .font(.system(size: 12, weight: .bold))
                            Text("STOP")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                .padding(12)
                
                Spacer()
            }
        }
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
                        .tint(.white)
                    Text("LOADING GAME...")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.green)
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

// Authentic NES Controller View
struct NESControllerView: View {
    @EnvironmentObject var emulatorManager: EmulatorManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Controller background with authentic gray color
            ZStack {
                // Main body
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.7, green: 0.7, blue: 0.7),
                                Color(red: 0.6, green: 0.6, blue: 0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                
                // Inner shadow for depth
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.black.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                
                HStack(spacing: 24) {
                    // D-Pad (Left side)
                    VStack(spacing: 2) {
                        Text("D-PAD")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 2) {
                            DPadButton(direction: "↑") {
                                emulatorManager.pressButton(.up)
                            } onRelease: {
                                emulatorManager.releaseButton(.up)
                            }
                            
                            HStack(spacing: 2) {
                                DPadButton(direction: "←") {
                                    emulatorManager.pressButton(.left)
                                } onRelease: {
                                    emulatorManager.releaseButton(.left)
                                }
                                
                                Color.clear.frame(width: 24, height: 24)
                                
                                DPadButton(direction: "→") {
                                    emulatorManager.pressButton(.right)
                                } onRelease: {
                                    emulatorManager.releaseButton(.right)
                                }
                            }
                            
                            DPadButton(direction: "↓") {
                                emulatorManager.pressButton(.down)
                            } onRelease: {
                                emulatorManager.releaseButton(.down)
                            }
                        }
                    }
                    .frame(width: 90)
                    
                    Spacer()
                    
                    // Start/Select buttons
                    VStack(spacing: 12) {
                        Text("SELECT     START")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(1)
                        
                        HStack(spacing: 24) {
                            NESSmallButton(label: "SELECT") {
                                emulatorManager.pressButton(.select)
                            } onRelease: {
                                emulatorManager.releaseButton(.select)
                            }
                            
                            NESSmallButton(label: "START") {
                                emulatorManager.pressButton(.start)
                            } onRelease: {
                                emulatorManager.releaseButton(.start)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // A/B Buttons (Right side)
                    VStack(spacing: 2) {
                        Text("A B")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(2)
                            .padding(.bottom, 4)
                        
                        HStack(spacing: 8) {
                            NESActionButton(label: "B", color: Color(red: 0.9, green: 0.2, blue: 0.2)) {
                                emulatorManager.pressButton(.b)
                            } onRelease: {
                                emulatorManager.releaseButton(.b)
                            }
                            
                            NESActionButton(label: "A", color: Color(red: 0.2, green: 0.7, blue: 0.2)) {
                                emulatorManager.pressButton(.a)
                            } onRelease: {
                                emulatorManager.releaseButton(.a)
                            }
                        }
                    }
                    .frame(width: 90)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .frame(height: 140)
            .padding(.horizontal, 12)
            
            // Grip handle at bottom
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                
                VStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        Capsule()
                            .fill(Color(red: 0.5, green: 0.5, blue: 0.5))
                            .frame(width: 40, height: 2)
                    }
                }
            }
            .frame(height: 24)
            .padding(.horizontal, 40)
        }
    }
}

// D-Pad Button
struct DPadButton: View {
    let direction: String
    let action: () -> Void
    let onRelease: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .shadow(
                        color: isPressed ? Color.black.opacity(0.8) : Color.black.opacity(0.3),
                        radius: isPressed ? 2 : 4,
                        x: 0,
                        y: isPressed ? 1 : 2
                    )
                
                Text(direction)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(width: 28, height: 28)
            .offset(y: isPressed ? 2 : 0)
        }
        .simultaneousGesture(
            DragGesture().onEnded { _ in
                isPressed = false
                onRelease()
            }
        )
    }
}

// A/B Action Buttons (Round)
struct NESActionButton: View {
    let label: String
    let color: Color
    let action: () -> Void
    let onRelease: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
        }) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.9),
                                color.opacity(0.7)
                            ]),
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: 35
                        )
                    )
                    .shadow(
                        color: Color.black.opacity(0.5),
                        radius: isPressed ? 2 : 6,
                        x: 0,
                        y: isPressed ? 1 : 3
                    )
                
                // Button shine
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    .padding(4)
                
                Text(label)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .frame(width: 56, height: 56)
            .offset(y: isPressed ? 3 : 0)
        }
        .simultaneousGesture(
            DragGesture().onEnded { _ in
                isPressed = false
                onRelease()
            }
        )
    }
}

// Select/Start Buttons
struct NESSmallButton: View {
    let label: String
    let action: () -> Void
    let onRelease: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
        }) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 50, height: 16)
                .background(Color(red: 0.4, green: 0.4, blue: 0.4))
                .cornerRadius(3)
                .shadow(
                    color: Color.black.opacity(0.5),
                    radius: isPressed ? 1 : 3,
                    x: 0,
                    y: isPressed ? 0 : 1
                )
                .offset(y: isPressed ? 1 : 0)
        }
        .simultaneousGesture(
            DragGesture().onEnded { _ in
                isPressed = false
                onRelease()
            }
        )
    }
}

#Preview {
    GameView()
        .environmentObject(EmulatorManager())
}
