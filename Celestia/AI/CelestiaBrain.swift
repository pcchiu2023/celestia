import Foundation
import MLXLLM
import MLXLMCommon
import MLX

@MainActor
final class CelestiaBrain: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isGenerating = false
    @Published var loadingProgress: String = "Awakening the stars..."

    private var container: ModelContainer?

    // MARK: - Model Loading

    func loadModel() async {
        loadingProgress = "Aligning the cosmos..."

        GPU.set(cacheLimit: 1024 * 1024 * 1024) // 1GB GPU cache

        guard let modelURL = findModelPath() else {
            loadingProgress = "Model not found"
            return
        }

        do {
            let config = ModelConfiguration(directory: modelURL)
            container = try await LLMModelFactory.shared.loadContainer(configuration: config)
            isModelLoaded = true
            loadingProgress = "The stars are ready"
        } catch {
            loadingProgress = "Failed to load: \(error.localizedDescription)"
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

    // MARK: - Model Path

    private func findModelPath() -> URL? {
        let modelName = "Qwen3.5-4B-MLX-4bit"

        // Check bundle resources
        if let url = Bundle.main.resourceURL?.appendingPathComponent(modelName) {
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        // Check bundle path directly
        if let url = Bundle.main.url(forResource: modelName, withExtension: nil) {
            return url
        }

        // Fallback: try HuggingFace download path (for development)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let url = documentsPath?.appendingPathComponent("models/\(modelName)") {
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        return nil
    }
}
