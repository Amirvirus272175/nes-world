import Foundation

class NESEmulator {
    private let cpu = CPU()
    private let ppu = PPU()
    private let apu = APU()
    let controller = ControllerInput()
    
    private var memory = [UInt8](repeating: 0, count: 0x10000) // 64KB RAM
    private var cartridge: Cartridge?
    private var isRunning = false
    private var emulationThread: Thread?
    
    func loadROM(_ data: Data) -> Bool {
        guard let cartridge = Cartridge(data: data) else {
            return false
        }
        self.cartridge = cartridge
        return true
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        emulationThread = Thread {
            while self.isRunning {
                self.runCycle()
            }
        }
        emulationThread?.start()
    }
    
    func stop() {
        isRunning = false
        emulationThread?.cancel()
    }
    
    private func runCycle() {
        // Execute one CPU cycle
        let cycles = cpu.execute(&memory)
        
        // PPU runs 3x faster than CPU
        for _ in 0..<(cycles * 3) {
            ppu.tick(&memory)
        }
        
        // APU processes sound
        apu.tick()
        
        // Frame timing (approximately 60 FPS)
        usleep(1)
    }
    
    func getFrameBuffer() -> [UInt8]? {
        return ppu.frameBuffer
    }
}

// MARK: - CPU (6502 Processor)
class CPU {
    var pc: UInt16 = 0x8000  // Program Counter
    var sp: UInt8 = 0xFD     // Stack Pointer
    var a: UInt8 = 0         // Accumulator
    var x: UInt8 = 0         // X Register
    var y: UInt8 = 0         // Y Register
    var flags: UInt8 = 0x24  // Status Flags
    
    func execute(_ memory: inout [UInt8]) -> Int {
        // Fetch opcode
        let opcode = memory[Int(pc)]
        pc = pc &+ 1
        
        // Decode and execute (simplified)
        switch opcode {
        case 0xEA: // NOP
            return 2
        case 0x69: // ADC Immediate
            return 2
        default:
            return 2
        }
    }
}

// MARK: - PPU (Picture Processing Unit)
class PPU {
    var frameBuffer = [UInt8](repeating: 0, count: 256 * 240 * 4)
    private var scanline = 0
    private var cycle = 0
    
    func tick(_ memory: inout [UInt8]) {
        cycle += 1
        
        if cycle >= 341 {
            cycle = 0
            scanline += 1
            
            if scanline >= 262 {
                scanline = 0
                renderFrame()
            }
        }
    }
    
    private func renderFrame() {
        // Render the current frame to frameBuffer
        // This is where graphics are drawn
    }
}

// MARK: - APU (Audio Processing Unit)
class APU {
    func tick() {
        // Process audio samples
    }
}

// MARK: - Cartridge
struct Cartridge {
    let prg: [UInt8]  // Program ROM
    let chr: [UInt8]  // Character ROM
    let mapper: UInt8
    let mirroring: Mirroring
    
    enum Mirroring {
        case horizontal
        case vertical
    }
    
    init?(data: Data) {
        guard data.count >= 16 else { return nil }
        
        // NES header validation (iNES format)
        guard data[0] == 0x4E, data[1] == 0x45, data[2] == 0x53, data[3] == 0x1A else {
            return nil
        }
        
        let prgRomSize = Int(data[4]) * 16384
        let chrRomSize = Int(data[5]) * 8192
        let controlByte = data[6]
        let controlByte2 = data[7]
        
        self.mapper = ((controlByte2 & 0xF0) | ((controlByte & 0xF0) >> 4))
        self.mirroring = (controlByte & 0x01) == 0 ? .horizontal : .vertical
        
        let headerSize = 16
        var offset = headerSize
        
        self.prg = Array(data[offset..<(offset + prgRomSize)])
        offset += prgRomSize
        
        self.chr = offset + chrRomSize <= data.count ? 
            Array(data[offset..<(offset + chrRomSize)]) : []
    }
}

// MARK: - Controller Input
class ControllerInput {
    var buttonState: UInt8 = 0
    
    enum Button: UInt8 {
        case a = 0x80
        case b = 0x40
        case select = 0x20
        case start = 0x10
        case up = 0x08
        case down = 0x04
        case left = 0x02
        case right = 0x01
    }
    
    func press(_ button: NESButton) {
        let bit = buttonToBit(button)
        buttonState |= bit
    }
    
    func release(_ button: NESButton) {
        let bit = buttonToBit(button)
        buttonState &= ~bit
    }
    
    private func buttonToBit(_ button: NESButton) -> UInt8 {
        switch button {
        case .a: return Button.a.rawValue
        case .b: return Button.b.rawValue
        case .select: return Button.select.rawValue
        case .start: return Button.start.rawValue
        case .up: return Button.up.rawValue
        case .down: return Button.down.rawValue
        case .left: return Button.left.rawValue
        case .right: return Button.right.rawValue
        }
    }
}

enum NESButton {
    case a, b, select, start, up, down, left, right
}