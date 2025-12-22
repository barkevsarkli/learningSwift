# 🤖 ChatGPT iOS Uygulaması

Modern MVVM mimarisi ile geliştirilmiş, profesyonel standartlara uygun bir iOS chat uygulaması.

## 📁 Proje Yapısı

```
04_ChatGPT_App/
├── Models/
│   └── Message.swift              # Veri modelleri (Message, ChatRequest, ChatResponse)
├── Services/
│   └── OpenAIService.swift        # OpenAI API iletişim servisi
├── ViewModels/
│   └── ChatViewModel.swift        # MVVM köprüsü - State management
└── Views/
    ├── ChatView.swift             # Ana chat ekranı
    └── MessageView.swift          # Mesaj baloncuğu bileşeni
```

## 🏗️ Mimari: MVVM (Model-View-ViewModel)

### Model Katmanı
**Dosya:** `Message.swift`

- **Görev:** Veri yapısını tanımlar
- **Teknik:** Struct (Value Type), Codable (JSON parsing), Identifiable (SwiftUI)
- **İçerik:** 
  - `Message`: Ana mesaj modeli
  - `ChatRequest`: OpenAI API'ye gönderilen istek formatı
  - `ChatResponse`: OpenAI API'den dönen cevap formatı

### Service Katmanı
**Dosya:** `OpenAIService.swift`

- **Görev:** Dış API ile iletişimi yönetir
- **Teknik:** URLSession, async/await, Error Handling
- **Özellikler:**
  - Asenkron HTTP istekleri
  - JSON Encoding/Decoding
  - Güvenli API key yönetimi
  - Detaylı hata yönetimi

### ViewModel Katmanı
**Dosya:** `ChatViewModel.swift`

- **Görev:** View ile Model/Service arasında köprü
- **Teknik:** ObservableObject, @Published, @MainActor
- **Sorumluluklar:**
  - State management (mesaj listesi, loading, error)
  - Business logic (mesaj gönderme, silme, temizleme)
  - Reactive programming (UI otomatik güncelleme)

### View Katmanı
**Dosyalar:** `ChatView.swift`, `MessageView.swift`

- **Görev:** Kullanıcı arayüzü
- **Teknik:** SwiftUI, Declarative UI
- **Özellikler:**
  - Modern, responsive tasarım
  - Otomatik scroll
  - Loading indicators
  - Error alerts
  - Context menu (kopyalama)

## 🚀 Kurulum ve Kullanım

### 1. API Key Ayarlama

`Services/OpenAIService.swift` dosyasını açın ve API key'inizi ekleyin:

```swift
private let apiKey = "sk-your-api-key-here"
```

> ⚠️ **Güvenlik Notu:** Production ortamında API key'i asla kodun içine yazmayın. Environment variable veya Keychain kullanın.

### 2. Xcode Projesi Oluşturma

1. Xcode'u açın
2. File → New → Project
3. iOS → App seçin
4. Interface: **SwiftUI**
5. Language: **Swift**
6. Oluşturulan projeye bu dosyaları ekleyin

### 3. Dosyaları Projeye Ekleme

- `Models/` klasörünü Xcode'a sürükleyin
- `Services/` klasörünü Xcode'a sürükleyin
- `ViewModels/` klasörünü Xcode'a sürükleyin
- `Views/` klasörünü Xcode'a sürükleyin

### 4. Ana Dosyayı Güncelleme

`YourAppNameApp.swift` dosyasını açın ve şu şekilde güncelleyin:

```swift
import SwiftUI

@main
struct ChatGPTApp: App {
    var body: some Scene {
        WindowGroup {
            ChatView()
        }
    }
}
```

### 5. Çalıştırma

- Simulator veya gerçek cihazda ⌘R ile çalıştırın
- Mesaj yazın ve "Gönder" butonuna tıklayın
- AI'ın cevabını bekleyin

## 🎯 Özellikler

### ✅ Mevcut Özellikler

- [x] OpenAI GPT-3.5 Turbo entegrasyonu
- [x] Gerçek zamanlı mesajlaşma
- [x] Otomatik scroll (en son mesaja)
- [x] Loading göstergesi
- [x] Hata yönetimi ve alertler
- [x] Mesaj kopyalama (long press)
- [x] Chat temizleme
- [x] Modern, responsive UI
- [x] Dark mode desteği (otomatik)

### 🔮 Gelecek Özellikler (TODO)

- [ ] Mesaj silme özelliği
- [ ] Chat geçmişi kaydetme (Core Data / UserDefaults)
- [ ] Farklı AI modelleri seçimi (GPT-4, GPT-3.5)
- [ ] Mesaj arama
- [ ] Markdown desteği
- [ ] Ses girişi (Speech-to-Text)
- [ ] Kod highlight (Syntax highlighting)
- [ ] Export chat (PDF, TXT)
- [ ] Özel sistem promptları
- [ ] Token sayacı ve maliyet hesaplama

## 🔧 Teknik Detaylar

### Kullanılan Teknolojiler

| Teknoloji | Kullanım Amacı |
|-----------|----------------|
| **SwiftUI** | Modern, declarative UI framework |
| **Combine** | Reactive programming (implicit) |
| **URLSession** | HTTP networking |
| **async/await** | Asenkron programlama |
| **Codable** | JSON parsing |
| **@Published** | State management |
| **ObservableObject** | ViewModel reaktivitesi |

### Performans Optimizasyonları

1. **LazyVStack**: Sadece görünen mesajları yükler
2. **@MainActor**: UI güncellemeleri main thread'de
3. **Struct kullanımı**: Value type, memory efficient
4. **Singleton pattern**: Tek servis instance'ı

### Bellek Yönetimi

- Struct'lar value type → Stack'te tutulur
- Class'lar reference type → Heap'te tutulur
- SwiftUI otomatik lifecycle yönetimi
- No retain cycles (weak/unowned gerekmez)

## 📱 Ekran Görüntüleri

```
┌─────────────────────────────┐
│       ChatGPT        🗑️     │  ← Navigation Bar
├─────────────────────────────┤
│  🧠 ChatGPT                 │
│  ┌───────────────────────┐ │
│  │ Merhaba! Size nasıl   │ │  ← AI Mesajı (Sol, Gri)
│  │ yardımcı olabilirim?  │ │
│  └───────────────────────┘ │
│                             │
│            ┌──────────────┐ │
│            │ Swift nasıl  │ │  ← User Mesajı (Sağ, Mavi)
│            │ öğrenilir?   │ │
│            └──────────────┘ │
│                             │
│  🧠 ChatGPT                 │
│  ┌───────────────────────┐ │
│  │ Swift öğrenmek için   │ │
│  │ şu kaynakları ...     │ │
│  └───────────────────────┘ │
│                             │
├─────────────────────────────┤
│ ┌─────────────────────┐  📤│  ← Input Box
│ │ Mesajınızı yazın... │  🔵│
│ └─────────────────────┘    │
└─────────────────────────────┘
```

## 🐛 Hata Ayıklama

### API Key Hatası
```
Hata: "API anahtarı eksik."
Çözüm: OpenAIService.swift'te API key'i ayarlayın
```

### Network Hatası
```
Hata: "HTTP Hatası: 401"
Çözüm: API key'in geçerli olduğundan emin olun
```

### Derleme Hatası
```
Hata: "Module not found"
Çözüm: Tüm dosyaların target'a eklendiğinden emin olun
```

## 📚 Öğrenme Kaynakları

### Swift & SwiftUI
- [Apple Swift Documentation](https://developer.apple.com/swift/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Hacking with Swift](https://www.hackingwithswift.com)

### OpenAI API
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [API Reference](https://platform.openai.com/docs/api-reference)
- [Pricing](https://openai.com/pricing)

### MVVM Mimarisi
- [Apple's Data Flow](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
- [MVVM Pattern](https://www.raywenderlich.com/34-design-patterns-by-tutorials-mvvm)

## 🤝 Katkıda Bulunma

Bu proje eğitim amaçlı oluşturulmuştur. İyileştirme önerileri:

1. API key'i environment variable'dan okuma
2. Core Data entegrasyonu
3. Unit test ekleme
4. UI test ekleme
5. Accessibility iyileştirmeleri

## 📄 Lisans

Bu proje eğitim amaçlıdır ve özgürce kullanılabilir.

## 👨‍💻 Geliştirici Notları

### Kod Standartları
- Swift API Design Guidelines'a uyulmuştur
- Her dosya tek bir sorumluluk prensibine (SRP) uyar
- MARK comment'leri ile kod organize edilmiştir
- Tüm public fonksiyonlar dokümante edilmiştir

### Test Edilebilirlik
- Dependency Injection kullanılmıştır (OpenAIService)
- ViewModel business logic içerir, test edilebilir
- Preview helpers eklenmiştir

### Genişletilebilirlik
- Protocol-oriented design (gelecekte eklenebilir)
- Modüler yapı (her katman bağımsız)
- Configuration file desteği eklenebilir

---

**İyi Kodlamalar! 🚀**

*Bu proje MVVM mimarisinin gücünü ve SwiftUI'ın esnekliğini göstermek için tasarlanmıştır.*
