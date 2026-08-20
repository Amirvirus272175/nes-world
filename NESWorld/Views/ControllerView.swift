import SwiftUI

// Legacy controller view - kept for reference but GameView now uses NESControllerView
struct ControllerView: View {
    @EnvironmentObject var emulatorManager: EmulatorManager
    
    var body: some View {
        NESControllerView()
            .environmentObject(emulatorManager)
    }
}

#Preview {
    ControllerView()
        .environmentObject(EmulatorManager())
}
