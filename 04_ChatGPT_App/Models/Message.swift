//
//  Message.swift
//  ChatGPT App
//
//  MODEL KATMANI - Veri Omurgası
//
//  Bu dosya uygulamanın veri modelini tanımlar.
//  Bir mesajın ne olduğunu, hangi özelliklere sahip olduğunu belirler.
//
//  Teknik Detaylar:
//  - Struct kullanımı: Value Type olduğu için küçük veriler için performanslı
//  - Identifiable: SwiftUI'ın liste elemanlarını birbirinden ayırt etmesi için
//  - Codable: JSON'dan Swift nesnesine otomatik dönüşüm (Parsing/Decoding)
//

import Foundation

/// Bir chat mesajını temsil eden veri modeli
///
/// Her mesaj 3 temel özelliğe sahiptir:
/// - Benzersiz kimlik (UUID)
/// - Mesaj içeriği (String)
/// - Gönderen bilgisi (Kullanıcı mı, Yapay Zeka mı?)
struct Message: Identifiable, Codable {
    /// Mesajın benzersiz kimliği - SwiftUI listeleri için gerekli
    let id: UUID
    
    /// Mesajın text içeriği
    let text: String
    
    /// Mesajın kullanıcı tarafından mı gönderildiğini belirten flag
    /// true: Kullanıcı mesajı, false: AI cevabı
    let isUser: Bool
    
    /// İsteğe bağlı: OpenAI API'nin kullandığı role alanı
    /// Değerler: "user", "assistant", "system"
    var role: String {
        return isUser ? "user" : "assistant"
    }
    
    // MARK: - Initializer
    
    /// Yeni bir mesaj oluşturur
    /// - Parameters:
    ///   - id: Benzersiz kimlik (varsayılan: otomatik UUID)
    ///   - text: Mesaj içeriği
    ///   - isUser: Kullanıcı mesajı mı?
    init(id: UUID = UUID(), text: String, isUser: Bool) {
        self.id = id
        self.text = text
        self.isUser = isUser
    }
}

// MARK: - OpenAI API Request/Response Models

/// OpenAI API'ye gönderilecek mesaj formatı
/// Bu struct, API'nin beklediği JSON formatına uygun olarak tasarlanmıştır
struct ChatMessage: Codable {
    let role: String    // "user", "assistant", veya "system"
    let content: String // Mesaj içeriği
}

/// OpenAI API'ye gönderilen isteğin tamamı
struct ChatRequest: Codable {
    let model: String           // Örn: "gpt-3.5-turbo", "gpt-4"
    let messages: [ChatMessage] // Konuşma geçmişi
    let temperature: Double?    // Yaratıcılık seviyesi (0-2 arası, varsayılan 1)
    let maxTokens: Int?         // Maksimum cevap uzunluğu
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens" // Snake case -> Camel case dönüşümü
    }
}

/// OpenAI API'den dönen cevabın yapısı
struct ChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?
    
    struct Choice: Codable {
        let index: Int
        let message: ChatMessage
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}
