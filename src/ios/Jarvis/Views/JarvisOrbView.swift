import SwiftUI
import MetalKit
import Combine

struct JarvisOrbView: View {
    @StateObject private var viewModel = JarvisOrbViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Metal View for 3D Orb
            MetalView(representable: viewModel.metalView)
                .frame(width: 200, height: 200)
                .cornerRadius(100)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .blur(radius: 5)
                )
                .shadow(color: .cyan.opacity(0.5), radius: 20, x: 0, y: 0)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                .onAppear {
                    isAnimating = true
                    viewModel.startAnimation()
                }
                .onDisappear {
                    viewModel.stopAnimation()
                }
            
            // Voice level indicator (pulsing effect)
            if viewModel.isListening {
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [.cyan.opacity(0.1), .cyan.opacity(0.4), .cyan.opacity(0.1)]),
                            center: .center
                        )
                    )
                    .frame(width: 220, height: 220)
                    .opacity(0.7)
                    .scaleEffect(viewModel.voiceLevel * 0.3 + 0.7)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.voiceLevel)
            }
        }
        .frame(width: 200, height: 200)
    }
}

// MARK: - Metal View for 3D Rendering

struct MetalView: UIViewRepresentable {
    var representable: MTKView
    
    func makeUIView(context: Context) -> MTKView {
        return representable
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update will be handled by the view model
    }
}

// MARK: - Jarvis Orb View Model

class JarvisOrbViewModel: NSObject, ObservableObject, MTKViewDelegate {
    @Published var isListening = false
    @Published var voiceLevel: CGFloat = 0.0
    
    var metalView: MTKView
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var renderer: OrbRenderer
    
    private var displayLink: CADisplayLink?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    override init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.metalView = MTKView(frame: .zero, device: device)
        self.renderer = OrbRenderer(device: device)
        
        super.init()
        
        setupMetalView()
        setupVoiceMonitoring()
    }
    
    private func setupMetalView() {
        metalView.delegate = self
        metalView.framebufferOnly = false
        metalView.drawableSize = metalView.frame.size
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
    }
    
    private func setupVoiceMonitoring() {
        // Simulate voice level changes for demo purposes
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.isListening {
                // Random voice level simulation
                self.voiceLevel = CGFloat.random(in: 0.1...1.0)
            } else {
                self.voiceLevel = 0.0
            }
        }
    }
    
    func startAnimation() {
        metalView.isPaused = false
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopAnimation() {
        metalView.isPaused = true
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func update() {
        metalView.setNeedsDisplay(metalView.frame)
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.resize(size: size)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        renderer.update()
        renderer.render(drawable: drawable, commandBuffer: commandBuffer)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // MARK: - Public Methods
    
    func startListening() {
        isListening = true
    }
    
    func stopListening() {
        isListening = false
    }
    
    func setVoiceLevel(_ level: CGFloat) {
        voiceLevel = max(0, min(1, level))
    }
}

// MARK: - Orb Renderer (Metal)

class OrbRenderer {
    private let device: MTLDevice
    private var pipelineState: MTLRenderPipelineState
    private var depthState: MTLDepthStencilState
    private var vertexBuffer: MTLBuffer
    private var indexBuffer: MTLBuffer
    private var uniformBuffer: MTLBuffer
    
    private var rotation: Float = 0
    private var lastUpdateTime: CFTimeInterval = 0
    
    init(device: MTLDevice) {
        self.device = device
        
        // Create pipeline state
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "vertexShader")!
        let fragmentFunction = library.makeFunction(name: "fragmentShader")!
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create pipeline state: \(error)")
        }
        
        // Create depth state
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        depthState = device.makeDepthStencilState(descriptor: depthDescriptor)!
        
        // Create sphere geometry
        (vertexBuffer, indexBuffer) = createSphereGeometry(device: device, radius: 1.0, segments: 32)
        
        // Create uniform buffer
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride * 16, options: [])!
    }
    
    func resize(size: CGSize) {
        // Handle resize if needed
    }
    
    func update() {
        rotation += 0.01
    }
    
    func render(drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        
        // Set uniforms
        var uniforms = [Float](repeating: 0, count: 16)
        uniforms[0] = rotation // Rotation angle
        
        uniformBuffer.contents().copyMemory(from: uniforms, byteCount: MemoryLayout<Float>.stride * 16)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        
        // Draw sphere
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                           indexCount: indexBuffer.length / MemoryLayout<UInt16>.stride,
                                           indexType: .uint16,
                                           indexBuffer: indexBuffer,
                                           indexBufferOffset: 0)
        
        renderEncoder.endEncoding()
    }
    
    private func createSphereGeometry(device: MTLDevice, radius: Float, segments: Int) -> (MTLBuffer, MTLBuffer) {
        var vertices = [Vertex]()
        var indices = [UInt16]()
        
        // Create vertices
        for i in 0..<segments {
            let theta = Float(i) * 2 * .pi / Float(segments)
            for j in 0..<segments {
                let phi = Float(j) * .pi / Float(segments)
                
                let x = radius * sin(phi) * cos(theta)
                let y = radius * cos(phi)
                let z = radius * sin(phi) * sin(theta)
                
                let u = Float(i) / Float(segments)
                let v = Float(j) / Float(segments)
                
                vertices.append(Vertex(position: SIMD3<Float>(x, y, z), 
                                      normal: SIMD3<Float>(x, y, z).normalized,
                                      texCoord: SIMD2<Float>(u, v)))
            }
        }
        
        // Create indices
        for i in 0..<segments-1 {
            for j in 0..<segments-1 {
                let current = UInt16(i * segments + j)
                let next = UInt16(i * segments + j + 1)
                let nextRow = UInt16((i + 1) * segments + j)
                let nextRowNext = UInt16((i + 1) * segments + j + 1)
                
                indices.append(contentsOf: [current, next, nextRow])
                indices.append(contentsOf: [next, nextRowNext, nextRow])
            }
        }
        
        // Create buffers
        let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        let indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.stride, options: [])!
        
        return (vertexBuffer, indexBuffer)
    }
}

// MARK: - Vertex Structure

struct Vertex {
    var position: SIMD3<Float>
    var normal: SIMD3<Float>
    var texCoord: SIMD2<Float>
}

// MARK: - Metal Shaders (would be in .metal file in real implementation)

/*
// Vertex Shader
vertex VertexOut vertexShader(
    device Vertex in[[stage_in]],
    constant float4x4 &modelViewProjectionMatrix [[buffer(1)]],
    constant float &rotation [[buffer(2)]]
) {
    VertexOut out;
    float4 position = float4(in.position, 1.0);
    position.xz = rotate(position.xz, rotation);
    out.position = modelViewProjectionMatrix * position;
    out.normal = normalize(modelViewProjectionMatrix * float4(in.normal, 0.0)).xyz;
    out.texCoord = in.texCoord;
    return out;
}

// Fragment Shader
fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
    float diffuse = max(0.0, dot(normalize(in.normal), lightDir));
    float3 color = mix(float3(0.0, 0.8, 1.0), float3(0.0, 0.4, 0.6), diffuse);
    return float4(color, 1.0);
}

// Helper function for rotation
float2 rotate(float2 v, float angle) {
    float2x2 rot = float2x2(cos(angle), -sin(angle),
                           sin(angle), cos(angle));
    return rot * v;
}
*/

// MARK: - Preview

struct JarvisOrbView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            JarvisOrbView()
        }
        .preferredColorScheme(.dark)
    }
}