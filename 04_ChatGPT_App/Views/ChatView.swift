//
//  ChatView.swift
//  ChatGPT App
//
//  UI KATMANI - Ana Chat Ekranı
//
//  Bu dosya kullanıcının gördüğü ana arayüzü oluşturur.
//  SwiftUI'ın declarative (bildirimsel) yapısını kullanır.
//
//  Teknik Detaylar:
//  - SwiftUI: Apple'ın modern UI framework'ü
//  - Declarative UI: "Nasıl çizilir?" yerine "Ne olmalı?" tanımlanır
//  - @StateObject: ViewModel'in lifecycle'ını yönetir
//  - Reactive: ViewModel değişince UI otomatik güncellenir
//

import SwiftUI

/// Ana chat arayüzü
///
/// Layout yapısı:
/// ┌─────────────────────┐
/// │  Navigation Bar     │ (Başlık, Temizle butonu)
/// ├─────────────────────┤
/// │                     │
/// │   Message List      │ (ScrollView + LazyVStack)
/// │   (Yukarı scroll)   │
/// │                     │
/// ├─────────────────────┤
/// │  Input Box + Send   │ (TextField + Button)
/// └─────────────────────┘
struct ChatView: View {
    
    // MARK: - Properties
    
    /// ViewModel - @StateObject ile lifecycle yönetimi
    /// Bu view ilk oluşturulduğunda viewModel de oluşturulur
    /// View yok edildiğinde viewModel de yok edilir
    @StateObject private var viewModel = ChatViewModel()
    
    /// Scroll kontrolü için - En alttaki mesaja otomatik scroll
    @Namespace private var bottomID
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Mesaj Listesi
                messageListSection
                
                // Alt Divider
                Divider()
                
                // Mesaj Giriş Alanı
                messageInputSection
            }
            .navigationTitle("ChatGPT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Temizle butonu
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.clearChat) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("Hata", isPresented: $viewModel.showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Bilinmeyen hata")
            }
        }
    }
    
    // MARK: - View Components (Alt Bileşenler)
    
    /// Mesajların gösterildiği scroll edilebilir liste
    private var messageListSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Her mesaj için MessageView oluştur
                    ForEach(viewModel.messages) { message in
                        MessageView(message: message)
                            .id(message.id)
                            .transition(.opacity) // Yumuşak geçiş efekti
                    }
                    
                    // Loading indicator (AI düşünürken)
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Düşünüyor...")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding()
                        .id(bottomID)
                    } else {
                        // Scroll anchor noktası
                        Color.clear
                            .frame(height: 1)
                            .id(bottomID)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _ in
                // Yeni mesaj gelince en alta scroll
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
            }
        }
    }
    
    /// Alt kısımdaki mesaj giriş alanı
    private var messageInputSection: some View {
        HStack(spacing: 12) {
            // Metin giriş alanı
            TextField("Mesajınızı yazın...", text: $viewModel.currentMessage, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .lineLimit(1...5) // Minimum 1, maksimum 5 satır
                .onSubmit {
                    // Enter tuşuna basınca gönder
                    viewModel.sendMessage()
                }
            
            // Gönder butonu
            Button(action: viewModel.sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        // Mesaj boşsa butonu disable et
                        viewModel.currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.gray
                            : Color.blue
                    )
                    .cornerRadius(20)
            }
            .disabled(viewModel.currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

#if DEBUG
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
#endif
