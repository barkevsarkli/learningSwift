//
//  OpenAIService.swift
//  ChatGPT App
//
//  SERVİS / NETWORKING KATMANI - Dış Dünyaya Açılan Kapı
//
//  Bu dosya, OpenAI API'si ile iletişimi yönetir.
//  Client-Server mimarisinde "Client" kısmını temsil eder.
//
//  Teknik Detaylar:
//  - URLSession: Apple'ın yerel HTTP networking kütüphanesi
//  - async/await: Asenkron programlama - UI donmaması için kritik
//  - JSON Encoding/Decoding: Swift nesneleri ↔ JSON dönüşümü
//  - Error Handling: Ağ hatalarını yakalama ve yönetme
//

import Foundation

/// OpenAI API ile iletişim kuran servis sınıfı
///
/// Sorumlulukları:
/// 1. API isteği hazırlama (Request Building)
/// 2. HTTP POST isteği gönderme
/// 3. Cevabı alma ve parse etme
/// 4. Hata yönetimi
class OpenAIService {
    
    // MARK: - Constants
    
    /// OpenAI API endpoint'i
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    /// API anahtarı - GÜVENLİK NOTU: Production'da Environment Variable kullanılmalı!
    /// Şu anda eğitim amaçlı hardcoded, gerçek projede .env dosyasında tutulmalı
    private let apiKey = "YOUR_API_KEY_HERE" // ⚠️ Buraya kendi API key'inizi yazın
    
    /// Kullanılacak AI modeli
    private let model = "gpt-3.5-turbo" // veya "gpt-4" (daha güçlü, daha pahalı)
    
    // MARK: - Singleton Pattern (İsteğe Bağlı)
    
    /// Uygulamanın her yerinden aynı servis instance'ına erişim sağlar
    static let shared = OpenAIService()
    
    // Private init singleton pattern için
    private init() {}
    
    // MARK: - Public Methods
    
    /// OpenAI'dan mesaj cevabı alır
    ///
    /// Bu fonksiyon asenkron çalışır (async). Çağrıldığında UI thread'i bloklamaz.
    /// Network isteği tamamlanana kadar bekler (await).
    ///
    /// - Parameter messages: Konuşma geçmişi (context için önemli)
    /// - Returns: AI'ın cevap metni
    /// - Throws: NetworkError veya DecodingError
    func sendMessage(messages: [Message]) async throws -> String {
        
        // 1. API KEY Kontrolü
        guard apiKey != "YOUR_API_KEY_HERE" else {
            throw NetworkError.missingAPIKey
        }
        
        // 2. URL Oluşturma
        guard let url = URL(string: apiURL) else {
            throw NetworkError.invalidURL
        }
        
        // 3. HTTP Request Hazırlama
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 4. Message Array'ini OpenAI formatına dönüştürme
        let chatMessages = messages.map { message in
            ChatMessage(role: message.role, content: message.text)
        }
        
        // 5. Request Body Oluşturma
        let requestBody = ChatRequest(
            model: model,
            messages: chatMessages,
            temperature: 0.7,    // 0: Deterministik, 2: Çok yaratıcı
            maxTokens: 1000      // Maksimum cevap uzunluğu (1 token ≈ 4 karakter)
        )
        
        // 6. JSON Encoding - Swift struct'ı JSON'a çevirme
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestBody)
        
        // 7. Network İsteği Gönderme (Asenkron)
        // await anahtar kelimesi: Bu satırda fonksiyon durur, cevap gelene kadar bekler
        // Ancak thread bloklanmaz, başka işler devam edebilir
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 8. HTTP Response Kontrolü
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // 9. JSON Decoding - JSON'ı Swift nesnesine çevirme
        let decoder = JSONDecoder()
        let chatResponse = try decoder.decode(ChatResponse.self, from: data)
        
        // 10. Cevap Metnini Çıkarma
        guard let firstChoice = chatResponse.choices.first else {
            throw NetworkError.noResponse
        }
        
        return firstChoice.message.content
    }
    
    // MARK: - Helper Methods
    
    /// API key'in geçerli olup olmadığını kontrol eder
    func isAPIKeyValid() -> Bool {
        return !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE"
    }
}

// MARK: - Error Types

/// Networking işlemlerinde oluşabilecek hatalar
enum NetworkError: LocalizedError {
    case invalidURL
    case missingAPIKey
    case invalidResponse
    case httpError(statusCode: Int)
    case noResponse
    case decodingError
    
    /// Kullanıcıya gösterilecek hata mesajı
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz API adresi."
        case .missingAPIKey:
            return "API anahtarı eksik. Lütfen OpenAIService.swift dosyasında API key'inizi ayarlayın."
        case .invalidResponse:
            return "Sunucudan geçersiz yanıt alındı."
        case .httpError(let statusCode):
            return "HTTP Hatası: \(statusCode). Lütfen API key ve network bağlantınızı kontrol edin."
        case .noResponse:
            return "Sunucudan yanıt alınamadı."
        case .decodingError:
            return "Veri işlenirken hata oluştu."
        }
    }
}
