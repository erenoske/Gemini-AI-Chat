//
//  ChatService.swift
//  swift-login-system
//
//  Created by eren on 8.07.2024.
//


import FirebaseFirestore
import FirebaseAuth

class ChatService {
    
    public static let shared = ChatService()
    
    private init() {}
    
    public func uploadMessage(with request: ChatMessageRequest) {
        let id = UUID().uuidString
        let chatId = request.id
        let message = request.parts
        let role = request.role
        let createdTime = Date().timeIntervalSince1970
        
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("messages")
            .document(id)
            .setData([
                "userid": userUID,
                "chatid": chatId,
                "message": message,
                "role": role,
                "createdTime": createdTime
            ]) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
    }
    
    public func uploadTitles(with title: String, and chatId: String) {
        let id = UUID().uuidString
        let createdTime = Date().timeIntervalSince1970
        
        guard let userUId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("titles")
            .document(id)
            .setData([
                "userid": userUId,
                "chatid": chatId,
                "title": title,
                "createdTime": createdTime
            ]) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
    }
    
    func fetchChatTitles(completion: @escaping ([ChatTitle]?, Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(nil, nil)
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("titles")
            .whereField("userid", isEqualTo: userUID)
            .order(by: "createdTime", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("Snapshot is nil")
                    completion(nil, nil)
                    return
                }
                
                var chatTitles: [ChatTitle] = []
                
                for document in documents {
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let chatId = data["chatid"] as? String ?? ""
                    let model = ChatTitle(chatId: chatId, title: title)
                    chatTitles.append(model)
                }
                
                completion(chatTitles, nil)
            }
    }
    
    func fetchChat(chatId: String, completion: @escaping([ChatModel]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("messages")
            .whereField("chatid", isEqualTo: chatId)
            .order(by: "createdTime", descending: false)
            .getDocuments { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil, error)
                    return
                }
                
                guard let documents = data?.documents else {
                    print("data is nil")
                    completion(nil, nil)
                    return
                }
                
                var chatModels : [ChatModel] = []
                
                
                
                for document in documents {
                    let data = document.data()
                    let role = data["role"] as? String ?? ""
                    let parts = data["message"] as? String ?? ""
                    let model = ChatModel(role: role, parts: parts, image: nil)
                    chatModels.append(model)
                }
                
                completion(chatModels, nil)
            }
        
    }
    
    func deleteTitle(chatId: String) {
        let db = Firestore.firestore()
        db.collection("titles").whereField("chatid", isEqualTo: chatId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
