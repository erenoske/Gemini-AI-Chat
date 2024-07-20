//
//  ChatViewModel.swift
//  swift-login-system
//
//  Created by eren on 1.07.2024.
//

import GoogleGenerativeAI
import UIKit

protocol ChatViewModelDelegate: AnyObject {
    func updateLastMessage(with message: String)
}

final class ChatViewModel {
    
    weak var delegate: ChatViewModelDelegate?
    
    private let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    
    public var firstMessage = true
    
    func sendMessage(with text: String, and history: [ChatModel]?, id: String, image: UIImage? = nil) {
        Task {
            do {
                let contentStream: AsyncThrowingStream<GenerateContentResponse, Error>
                
                if let history = history {
                    let testHistory: [ModelContent] = history.map { convertToModelContent($0) }
                    let chat = model.startChat(history: testHistory)
                    
                    if let image = image {
                        contentStream = chat.sendMessageStream(text, image)
                    } else {
                        contentStream = chat.sendMessageStream(text)
                    }
                } else {
                    if let image = image {
                        contentStream = model.generateContentStream(text, image)
                    } else {
                        contentStream = model.generateContentStream(text)
                    }
                }
                
                var fullResponse = ""
                for try await chunk in contentStream {
                    if let text = chunk.text {
                        delegate?.updateLastMessage(with: text)
                        fullResponse += text
                        await Task.yield()
                    }
                }
                
                guard !fullResponse.isEmpty else { return }
                
                let userModel = ChatMessageRequest(id: id, role: "user", parts: text)
                ChatService.shared.uploadMessage(with: userModel)
                
                let modelResponse = ChatMessageRequest(id: id, role: "model", parts: fullResponse)
                ChatService.shared.uploadMessage(with: modelResponse)
                
                if firstMessage {
                    ChatService.shared.uploadTitles(with: text, and: id)
                    firstMessage = false
                }
                
            } catch {
                delegate?.updateLastMessage(with: error.localizedDescription)
            }
        }
    }
    
    private func convertToModelContent(_ chatModel: ChatModel) -> ModelContent {
        return ModelContent(role: chatModel.role, parts: chatModel.parts)
    }
}
