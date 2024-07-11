//
//  ChatViewModel.swift
//  swift-login-system
//
//  Created by eren on 1.07.2024.
//

import Foundation
import GoogleGenerativeAI
import UIKit

protocol ChatViewModelDelegate: AnyObject {
    func updateLastMessage(with message: String)
}

final class ChatViewModel {
    
    weak var delegate: ChatViewModelDelegate?
    
    private let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    
    public var firstMessage = true
    
    func sendMessage(with text: String, and history: [ChatModel]?, id: String , image: UIImage? = nil) {
        Task {
            do {
                let response: GenerateContentResponse
                
                if let history = history {
                    let testHistory: [ModelContent] = history.map { convertToModelContent($0) }
                    let chat = model.startChat(history: testHistory)
                    
                    if let image = image {
                        response = try await chat.sendMessage(text, image)
                    } else {
                        response = try await chat.sendMessage(text)
                    }
                } else {
                    if let image = image {
                        response = try await model.generateContent(text, image)
                    } else {
                        response = try await model.generateContent(text)
                    }
                }
                
                guard let textResponse = response.text else { return }
                
                let userModel = ChatMessageRequest(id: id, role: "user", parts: text)
                ChatService.shared.uploadMessage(with: userModel)
                
                let model = ChatMessageRequest(id: id, role: "model", parts: textResponse)
                ChatService.shared.uploadMessage(with: model)
                
                if firstMessage {
                    ChatService.shared.uploadTitles(with: text, and: id)
                    firstMessage = false
                }
                
                delegate?.updateLastMessage(with: textResponse)
                
            } catch {
                delegate?.updateLastMessage(with: error.localizedDescription)
            }
        }
    }
    
    private func convertToModelContent(_ chatModel: ChatModel) -> ModelContent {
        return ModelContent(role: chatModel.role, parts: chatModel.parts)
    }
}
