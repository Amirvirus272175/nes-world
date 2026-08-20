import SwiftUI

struct ControllerView: View {
    @EnvironmentObject var emulatorManager: EmulatorManager
    
    var body: some View {
        HStack(spacing: 40) {
            // D-Pad
            VStack(spacing: 8) {
                Button(action: { emulatorManager.pressButton(.up) }) {
                    Image(systemName: "chevron.up")
                        .frame(width: 44, height: 44)
                }
                .simultaneousGesture(DragGesture().onEnded { _ in
                    emulatorManager.releaseButton(.up)
                })
                
                HStack(spacing: 8) {
                    Button(action: { emulatorManager.pressButton(.left) }) {
                        Image(systemName: "chevron.left")
                            .frame(width: 44, height: 44)
                    }
                    .simultaneousGesture(DragGesture().onEnded { _ in
                        emulatorManager.releaseButton(.left)
                    })
                    
                    Color.clear.frame(width: 44, height: 44)
                    
                    Button(action: { emulatorManager.pressButton(.right) }) {
                        Image(systemName: "chevron.right")
                            .frame(width: 44, height: 44)
                    }
                    .simultaneousGesture(DragGesture().onEnded { _ in
                        emulatorManager.releaseButton(.right)
                    })
                }
                
                Button(action: { emulatorManager.pressButton(.down) }) {
                    Image(systemName: "chevron.down")
                        .frame(width: 44, height: 44)
                }
                .simultaneousGesture(DragGesture().onEnded { _ in
                    emulatorManager.releaseButton(.down)
                })
            }
            
            Spacer()
            
            // Start/Select
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ControlButton(title: "SELECT") {
                        emulatorManager.pressButton(.select)
                    } onRelease: {
                        emulatorManager.releaseButton(.select)
                    }
                    ControlButton(title: "START") {
                        emulatorManager.pressButton(.start)
                    } onRelease: {
                        emulatorManager.releaseButton(.start)
                    }
                }
                
                Spacer().frame(height: 20)
            }
            
            Spacer()
            
            // A/B Buttons
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    CircleButton(label: "B", color: .red) {
                        emulatorManager.pressButton(.b)
                    } onRelease: {
                        emulatorManager.releaseButton(.b)
                    }
                    
                    CircleButton(label: "A", color: .green) {
                        emulatorManager.pressButton(.a)
                    } onRelease: {
                        emulatorManager.releaseButton(.a)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray4))
        .cornerRadius(12)
    }
}

struct CircleButton: View {
    let label: String
    let color: Color
    let action: () -> Void
    let onRelease: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .clipShape(Circle())
        }
        .simultaneousGesture(DragGesture().onEnded { _ in
            onRelease()
        })
    }
}

struct ControlButton: View {
    let title: String
    let action: () -> Void
    let onRelease: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray))
                .foregroundColor(.white)
                .cornerRadius(6)
        }
        .simultaneousGesture(DragGesture().onEnded { _ in
            onRelease()
        })
    }
}

#Preview {
    ControllerView()
        .environmentObject(EmulatorManager())
}