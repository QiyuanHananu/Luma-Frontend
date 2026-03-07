//
//  ChatService.swift
//  Luma
//

import Foundation

private struct ChatMessageUploadRequest: Encodable {
    let message: String
    let is_from_user: Bool
    let client_message_id: String
}

private struct ChatMessageUploadResponse: Decodable {
    let id: Int
}

final class ChatService {
    static let shared = ChatService()
    private init() {}

    func upload(conversation: Conversation) async {
        let request = ChatMessageUploadRequest(
            message: conversation.message,
            is_from_user: conversation.isFromUser,
            client_message_id: conversation.id.uuidString
        )

        do {
            let _: ChatMessageUploadResponse = try await APIClient.shared.request(
                path: "/api/chat/messages/",
                method: "POST",
                body: request,
                requiresAuth: true
            )
            print("☁️ Chat synced:", conversation.id.uuidString)
        } catch {
            print("⚠️ Chat sync failed:", error.localizedDescription)
        }
    }
}
