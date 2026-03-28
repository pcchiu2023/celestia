import Foundation
import MLXVLM
import MLXLMCommon
import MLX

@MainActor
final class CelestiaBrain: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isGenerating = false
    @Published var loadingProgress: String = "Awakening the stars..."
    @Published var modelLoadFailed = false

    private var container: ModelContainer?

    // MARK: - Model Loading (from bundled resources)

    func loadModel() async {
        #if targetEnvironment(simulator)
        loadingProgress = "Simulator mode"
        modelLoadFailed = true
        isModelLoaded = true
        return
        #endif

        loadingProgress = "Aligning the cosmos..."

        GPU.set(cacheLimit: 2 * 1024 * 1024 * 1024) // 2GB GPU cache for 4B model

        // Load from bundled model directory
        guard let modelURL = Bundle.main.resourceURL?.appendingPathComponent("MLXModel") else {
            loadingProgress = "The stars are resting"
            modelLoadFailed = true
            isModelLoaded = true
            return
        }

        let modelConfig = ModelConfiguration(
            directory: modelURL
        )

        do {
            loadingProgress = "Loading star charts..."
            container = try await VLMModelFactory.shared.loadContainer(
                configuration: modelConfig
            ) { progress in
                Task { @MainActor in
                    let pct = Int(progress.fractionCompleted * 100)
                    self.loadingProgress = "Aligning the cosmos... \(pct)%"
                }
            }
            modelLoadFailed = false
            isModelLoaded = true
            loadingProgress = "The stars are ready"
        } catch {
            loadingProgress = "The stars are resting"
            modelLoadFailed = true
            isModelLoaded = true // Allow app to function with fallback
        }
    }

    // MARK: - Text Generation

    func generate(systemPrompt: String, userPrompt: String) async -> String {
        guard let container else { return "" }
        isGenerating = true
        defer { isGenerating = false }

        let messages: [Chat.Message] = [
            .system(systemPrompt),
            .user(userPrompt)
        ]

        do {
            let input = UserInput(chat: messages)
            let lmInput = try await container.prepare(input: input)
            let params = GenerateParameters(
                maxTokens: 300,
                temperature: 0.85,
                topP: 0.92,
                repetitionPenalty: 1.15
            )

            var fullResponse = ""
            let stream = try await container.generate(input: lmInput, parameters: params)

            for await generation in stream {
                switch generation {
                case .chunk(let text):
                    fullResponse += text
                case .info, .toolCall:
                    break
                }
            }

            return fullResponse
        } catch {
            return ""
        }
    }
}
