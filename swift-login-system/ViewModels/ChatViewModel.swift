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

class ChatViewModel {
    
    weak var delegate: ChatViewModelDelegate?
    
    private let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    
    func sendMessage(with text: String, and history: [ChatModel]?, image: UIImage? = nil) {
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
