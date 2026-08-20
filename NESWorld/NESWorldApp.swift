import SwiftUI

@main
struct NESWorldApp: App {
    @StateObject var emulatorManager = EmulatorManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(emulatorManager)
        }
    }
}