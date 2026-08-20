import Foundation

class EmulatorManager: ObservableObject {
    @Published var isGameLoaded = false
    @Published var currentGame: String?
    @Published var recentGames: [String] = []
    
    private var emulator: NESEmulator?
    private let emulationQueue = DispatchQueue(label: "com.nes-world.emulation", qos: .userInteractive)
    
    func loadROM(from url: URL) {
        do {
            let romData = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            
            emulationQueue.async {
                let emulator = NESEmulator()
                if emulator.loadROM(romData) {
                    DispatchQueue.main.async {
                        self.emulator = emulator
                        self.currentGame = fileName
                        self.isGameLoaded = true
                        self.addToRecent(fileName)
                        emulator.start()
                    }
                }
            }
        } catch {
            print("Error loading ROM: \(error)")
        }
    }
    
    func loadGame(_ gameName: String) {
        currentGame = gameName
        isGameLoaded = true
    }
    
    func unloadGame() {
        emulator?.stop()
        emulator = nil
        isGameLoaded = false
        currentGame = nil
    }
    
    private func addToRecent(_ gameName: String) {
        recentGames.removeAll { $0 == gameName }
        recentGames.insert(gameName, at: 0)
        if recentGames.count > 5 {
            recentGames.removeLast()
        }
    }
    
    func pressButton(_ button: NESButton) {
        emulator?.controller.press(button)
    }
    
    func releaseButton(_ button: NESButton) {
        emulator?.controller.release(button)
    }
    
    func getFrameBuffer() -> [UInt8]? {
        return emulator?.getFrameBuffer()
    }
}