# NES World - iOS NES Emulator

A Nintendo Entertainment System (NES) emulator for iOS built with Swift and SwiftUI.

## Features

- Load and play NES ROM files (.nes)
- SwiftUI-based interface
- Virtual controller for gameplay
- Game library management

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Project Structure

```
nes-world/
├── NESWorld/
│   ├── App/
│   │   ├── NESWorldApp.swift
│   │   └── ContentView.swift
│   ├── Emulator/
│   │   ├── NESEmulator.swift
│   │   ├── CPU.swift
│   │   ├── PPU.swift
│   │   └── APU.swift
│   ├── Views/
│   │   ├── GameView.swift
│   │   ├── ControllerView.swift
│   │   └── GameLibraryView.swift
│   └── Models/
│       ├── GameROM.swift
│       └── EmulatorState.swift
├── NESWorldTests/
└── README.md
```

## Getting Started

1. Open `NESWorld.xcodeproj` in Xcode
2. Select an iOS simulator or device
3. Build and run: ⌘R
4. Load a NES ROM file to start playing

## Building the Emulator

The emulator consists of several core components:
- **CPU**: 6502 processor emulation
- **PPU**: Picture Processing Unit for graphics
- **APU**: Audio Processing Unit for sound
- **Memory**: RAM and cartridge management

## License

MIT License