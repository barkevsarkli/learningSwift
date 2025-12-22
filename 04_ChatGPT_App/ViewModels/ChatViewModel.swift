//
//  ChatViewModel.swift
//  ChatGPT App
//
//  VIEWMODEL KATMANI - MVVM Mimarisinin Köprüsü
//
//  Bu dosya View ile Model/Service arasında iletişimi sağlar.
//  UI (View) mantığından iş mantığını (Business Logic) ayırır.
//
//  Teknik Detaylar:
//  - ObservableObject: SwiftUI'ın state management protokolü
//  - @Published: Bu property değişince UI otomatik güncellenir (reactive programming)
//  - @MainActor: UI güncellemelerinin main thread'de olmasını garanti eder
//  - Separation of Concerns: View asla doğrudan Service'i çağırmaz
//

import Foundation
import SwiftUI

/// Chat ekranının state'ini ve business logic'ini yöneten ViewModel
///
/// Sorumlulukları:
/// 1. Mesaj listesini tutma ve güncelleme
/// 2. User input'u işleme
/// 3. OpenAI Service'i koordine etme
/// 4. Loading/Error state'lerini yönetme
/// 5. UI'a veri sağlama
@MainActor // UI güncellemeleri için main thread garantisi
class ChatViewModel: ObservableObject {
    
    // MARK: - Published Properties (Reactive State)
    
    /// Ekranda gösterilecek tüm mesajlar
    /// @Published: Bu array değiştiğinde SwiftUI otomatik olarak UI'ı günceller
    @Published var messages: [Message] = []
    
    /// Kullanıcının şu anda yazdığı metin
    @Published var currentMessage: String = ""
    
    /// API isteği devam ediyor mu? (Loading spinner göstermek için)
    @Published var isLoading: Bool = false
    
    /// Hata durumu (Alert göstermek için)
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Private Properties
    
    /// OpenAI Service instance'ı
    private let openAIService: OpenAIService
    
    // MARK: - Initializer
    
    /// ViewModel'i başlatır
    /// - Parameter service: Test edilebilirlik için dependency injection
    init(service: OpenAIService = .shared) {
        self.openAIService = service
        
        // Hoş geldin mesajı ekle (isteğe bağlı)
        addWelcomeMessage()
    }
    
    // MARK: - Public Methods (View'ın çağıracağı fonksiyonlar)
    
    /// Kullanıcının mesajını gönderir ve AI cevabını alır
    ///
    /// Bu fonksiyon şu işlemleri yapar:
    /// 1. Kullanıcı mesajını listeye ekler
    /// 2. Loading state'i başlatır
    /// 3. OpenAI Service'i asenkron olarak çağırır
    /// 4. AI cevabını listeye ekler
    /// 5. Hataları yakalar ve kullanıcıya gösterir
    func sendMessage() {
        // Boş mesaj kontrolü
        guard !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Mesajı geçici değişkene al ve input'u temizle
        let userMessageText = currentMessage
        currentMessage = ""
        
        // Kullanıcı mesajını listeye ekle
        let userMessage = Message(text: userMessageText, isUser: true)
        messages.append(userMessage)
        
        // Loading state'i başlat
        isLoading = true
        
        // Asenkron olarak AI'dan cevap al
        Task {
            do {
                // OpenAI Service'i çağır (await ile bekle)
                let aiResponse = try await openAIService.sendMessage(messages: messages)
                
                // AI cevabını listeye ekle
                let aiMessage = Message(text: aiResponse, isUser: false)
                messages.append(aiMessage)
                
            } catch let error as NetworkError {
                // Network hatasını yakala ve göster
                handleError(error.errorDescription ?? "Bilinmeyen hata")
            } catch {
                // Genel hataları yakala
                handleError("Bir hata oluştu: \(error.localizedDescription)")
            }
            
            // Loading state'i bitir
            isLoading = false
        }
    }
    
    /// Konuşmayı temizler (Yeni chat başlatmak için)
    func clearChat() {
        messages.removeAll()
        addWelcomeMessage()
        errorMessage = nil
        showError = false
    }
    
    /// Belirli bir mesajı siler
    /// - Parameter message: Silinecek mesaj
    func deleteMessage(_ message: Message) {
        messages.removeAll { $0.id == message.id }
    }
    
    // MARK: - Private Helper Methods
    
    /// Hoş geldin mesajını ekler
    private func addWelcomeMessage() {
        let welcomeMessage = Message(
            text: "Merhaba! Ben ChatGPT. Size nasıl yardımcı olabilirim?",
            isUser: false
        )
        messages.append(welcomeMessage)
    }
    
    /// Hata mesajını işler ve kullanıcıya gösterir
    /// - Parameter message: Hata mesajı
    private func handleError(_ message: String) {
        errorMessage = message
        showError = true
        
        // Debug için console'a yazdır
        print("❌ Error: \(message)")
    }
}

// MARK: - Preview Helper

#if DEBUG
extension ChatViewModel {
    /// SwiftUI Preview için örnek data ile ViewModel
    static var preview: ChatViewModel {
        let viewModel = ChatViewModel()
        viewModel.messages = [
            Message(text: "Merhaba!", isUser: true),
            Message(text: "Merhaba! Size nasıl yardımcı olabilirim?", isUser: false),
            Message(text: "Swift öğrenmek istiyorum", isUser: true),
            Message(text: "Harika! Swift modern ve güçlü bir programlama dilidir. Nereden başlamak istersiniz?", isUser: false)
        ]
        return viewModel
    }
}
#endif
