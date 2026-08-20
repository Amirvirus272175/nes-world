import SwiftUI

struct ContentView: View {
    @EnvironmentObject var emulatorManager: EmulatorManager
    @State private var showingFilePicker = false
    
    var body: some View {
        ZStack {
            if emulatorManager.isGameLoaded {
                GameView()
                    .environmentObject(emulatorManager)
            } else {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("NES World")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("iOS NES Emulator")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 40)
                    
                    Button(action: { showingFilePicker = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "folder.badge.plus")
                            Text("Load ROM File")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    if !emulatorManager.recentGames.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Games")
                                .font(.headline)
                            
                            ForEach(emulatorManager.recentGames, id: \.self) { game in
                                Button(action: { emulatorManager.loadGame(game) }) {
                                    HStack {
                                        Image(systemName: "gamecontroller")
                                        Text(game)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                }
                .padding()
                .fileImporter(
                    isPresented: $showingFilePicker,
                    allowedContentTypes: [.data],
                    onCompletion: { result in
                        switch result {
                        case .success(let url):
                            emulatorManager.loadROM(from: url)
                        case .failure(let error):
                            print("File selection error: \(error)")
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(EmulatorManager())
}