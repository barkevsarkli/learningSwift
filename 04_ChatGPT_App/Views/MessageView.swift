//
//  MessageView.swift
//  ChatGPT App
//
//  UI BILEŞEN - Tek Mesaj Baloncuğu
//
//  Bu dosya tek bir mesajın nasıl görüneceğini tanımlar.
//  WhatsApp, iMessage gibi uygulamalardaki mesaj baloncuklarına benzer.
//
//  Teknik Detaylar:
//  - Reusable Component: ChatView'da her mesaj için kullanılır
//  - Conditional Styling: Kullanıcı/AI mesajı için farklı görünüm
//  - DRY Prensibi: Don't Repeat Yourself - kod tekrarını önler
//

import SwiftUI

/// Tek bir chat mesajını görselleştiren view
///
/// Tasarım Özellikleri:
/// - Kullanıcı mesajı: Sağda, mavi, beyaz text
/// - AI mesajı: Solda, gri, siyah text
/// - Yuvarlatılmış köşeler (rounded corners)
/// - Padding ve spacing profesyonel görünüm için
struct MessageView: View {
    
    // MARK: - Properties
    
    /// Görüntülenecek mesaj
    let message: Message
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // Sol boşluk (kullanıcı mesajı için)
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            // İçerik
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                
                // Avatar/İkon (isteğe bağlı)
                if !message.isUser {
                    avatarView
                }
                
                // Mesaj baloncuğu
                Text(message.text)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(backgroundColor)
                    .cornerRadius(20)
                    .contextMenu {
                        // Uzun basınca kopyalama menüsü
                        Button(action: {
                            UIPasteboard.general.string = message.text
                        }) {
                            Label("Kopyala", systemImage: "doc.on.doc")
                        }
                    }
                
                // Zaman damgası (isteğe bağlı - şimdilik yok)
                // timestampView
            }
            
            // Sağ boşluk (AI mesajı için)
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - View Components
    
    /// Avatar ikonu (AI için)
    private var avatarView: some View {
        HStack(spacing: 6) {
            Image(systemName: "brain.head.profile")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("ChatGPT")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    /// Zaman damgası view'u (gelecekte eklenebilir)
    private var timestampView: some View {
        Text(Date(), style: .time)
            .font(.caption2)
            .foregroundColor(.secondary)
    }
    
    /// Mesaj arka plan rengi (kullanıcı/AI'ya göre)
    private var backgroundColor: Color {
        message.isUser ? Color.blue : Color(.systemGray5)
    }
}

// MARK: - Preview

#if DEBUG
struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Kullanıcı mesajı örneği
            MessageView(
                message: Message(
                    text: "Merhaba! Swift nasıl öğrenilir?",
                    isUser: true
                )
            )
            
            // AI mesajı örneği
            MessageView(
                message: Message(
                    text: "Merhaba! Swift öğrenmek için Apple'ın resmi dokümantasyonunu ve Swift Playgrounds uygulamasını öneririm. Ayrıca pratik yaparak öğrenmek çok önemlidir.",
                    isUser: false
                )
            )
            
            // Uzun mesaj örneği
            MessageView(
                message: Message(
                    text: """
                    Swift öğrenirken şu adımları izleyebilirsiniz:
                    
                    1. Temel syntax'ı öğrenin
                    2. Playground'da pratik yapın
                    3. Küçük projeler geliştirin
                    4. iOS geliştirmeye başlayın
                    5. Sürekli pratik yapın
                    
                    Başarılar dilerim!
                    """,
                    isUser: false
                )
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
