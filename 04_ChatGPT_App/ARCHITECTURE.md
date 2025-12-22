# 🏗️ Mimari Dokümantasyonu - ChatGPT iOS Uygulaması

## 📊 Genel Bakış

Bu doküman, projenin mühendislik perspektifinden detaylı teknik açıklamasını içerir.

## 🎯 Mimari Prensipler

### 1. MVVM (Model-View-ViewModel) Pattern

```
┌─────────────────────────────────────────────────────────┐
│                         VIEW                             │
│                    (ChatView.swift)                      │
│                  (MessageView.swift)                     │
│                                                           │
│  - Kullanıcı arayüzü                                     │
│  - User input handling                                   │
│  - UI state rendering                                    │
└──────────────────────┬──────────────────────────────────┘
                       │
                       │ @StateObject / @Published
                       │ (Reactive Binding)
                       ▼
┌─────────────────────────────────────────────────────────┐
│                      VIEWMODEL                           │
│                 (ChatViewModel.swift)                    │
│                                                           │
│  - State management (@Published properties)              │
│  - Business logic                                        │
│  - Koordinasyon (View ↔ Service)                        │
│  - Error handling                                        │
└──────────────────────┬──────────────────────────────────┘
                       │
                       │ Function Calls
                       │ (async/await)
                       ▼
┌─────────────────────────────────────────────────────────┐
│                       SERVICE                            │
│                 (OpenAIService.swift)                    │
│                                                           │
│  - API communication (URLSession)                        │
│  - Network requests                                      │
│  - JSON encoding/decoding                                │
│  - Error handling                                        │
└──────────────────────┬──────────────────────────────────┘
                       │
                       │ Data Transfer Objects
                       │ (Codable structs)
                       ▼
┌─────────────────────────────────────────────────────────┐
│                        MODEL                             │
│                    (Message.swift)                       │
│                                                           │
│  - Veri yapıları (struct)                               │
│  - Codable protokolleri                                 │
│  - Business entities                                    │
└─────────────────────────────────────────────────────────┘
```

### 2. Separation of Concerns (İlgi Alanlarının Ayrılması)

Her katman sadece kendi sorumluluğuna odaklanır:

| Katman | Sorumluluğu | Ne Yapmaz |
|--------|-------------|-----------|
| **View** | UI rendering, user events | API çağrısı, business logic |
| **ViewModel** | State management, koordinasyon | UI rendering, network details |
| **Service** | API communication | UI state, business logic |
| **Model** | Data structure | Herhangi bir logic |

## 🔍 Dosya Bazlı Analiz

### 1. Message.swift (MODEL)

**Rol:** Veri Omurgası

**Teknik Özellikler:**
```swift
struct Message: Identifiable, Codable {
    let id: UUID          // SwiftUI Liste için
    let text: String      // Mesaj içeriği
    let isUser: Bool      // Gönderen bilgisi
    var role: String      // OpenAI API formatı
}
```

**Neden Struct?**
- Value Type → Stack'te tutulur (performans)
- Copy-on-write mekanizması
- Thread-safe (immutable)
- SwiftUI için optimize

**Protokoller:**
- `Identifiable`: SwiftUI liste rendering için unique ID
- `Codable`: JSON ↔ Swift otomatik dönüşüm

**API Transfer Objects:**
- `ChatMessage`: API mesaj formatı
- `ChatRequest`: İstek body'si
- `ChatResponse`: Cevap body'si

### 2. OpenAIService.swift (SERVICE)

**Rol:** Dış Dünya ile İletişim

**Teknik Özellikler:**

```swift
class OpenAIService {
    // Singleton pattern
    static let shared = OpenAIService()
    
    // Async networking
    func sendMessage(messages: [Message]) async throws -> String
}
```

**Asenkron Programlama:**
```swift
// await: Bu satırda fonksiyon durur, cevap bekler
// Ancak thread bloklanmaz!
let (data, response) = try await URLSession.shared.data(for: request)
```

**Error Handling:**
```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case missingAPIKey
    case httpError(statusCode: Int)
    case noResponse
}
```

**HTTP Request Anatomy:**
```
POST https://api.openai.com/v1/chat/completions
Headers:
  Content-Type: application/json
  Authorization: Bearer sk-xxx...

Body:
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {"role": "user", "content": "Merhaba"}
  ],
  "temperature": 0.7,
  "max_tokens": 1000
}
```

### 3. ChatViewModel.swift (VIEWMODEL)

**Rol:** MVVM Köprüsü

**Teknik Özellikler:**

```swift
@MainActor // UI thread garantisi
class ChatViewModel: ObservableObject {
    // Reactive state
    @Published var messages: [Message] = []
    @Published var currentMessage: String = ""
    @Published var isLoading: Bool = false
    
    // Business logic
    func sendMessage() { ... }
    func clearChat() { ... }
}
```

**@MainActor Neden Gerekli?**
```swift
// ❌ Hatalı (crash riski):
Task {
    let response = await service.fetch()
    self.data = response // Background thread'de UI güncelleme!
}

// ✅ Doğru:
@MainActor
Task {
    let response = await service.fetch()
    self.data = response // Main thread'de UI güncelleme
}
```

**Reactive Programming Flow:**
```
1. User tıklar "Gönder" → sendMessage() çağrılır
2. messages.append(userMessage) → @Published tetiklenir
3. SwiftUI @Published'i algılar → body yeniden çalışır
4. UI otomatik güncellenir (mesaj listesinde yeni item)
```

### 4. ChatView.swift (VIEW)

**Rol:** Ana Kullanıcı Arayüzü

**Teknik Özellikler:**

```swift
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        // Declarative UI tanımı
    }
}
```

**@StateObject vs @ObservedObject:**
```swift
// @StateObject: View'ın lifecycle'ı boyunca aynı instance
// View yeniden oluşturulsa bile viewModel korunur

// @ObservedObject: Parent'tan gelen instance
// View yeniden oluşturulunca reset edilebilir
```

**Layout Hierarşisi:**
```
NavigationView
└── VStack
    ├── ScrollViewReader
    │   └── ScrollView
    │       └── LazyVStack  (🔑 Performans!)
    │           └── ForEach(messages)
    │               └── MessageView
    ├── Divider
    └── HStack (Input Section)
        ├── TextField
        └── Button
```

**LazyVStack vs VStack:**
```swift
// VStack: Tüm child'ları hemen oluşturur
// 1000 mesaj → 1000 view instance

// LazyVStack: Sadece görünenleri oluşturur
// 1000 mesaj → ~10 view instance (ekrana sığan kadar)
// 🚀 Bellek tasarrufu!
```

### 5. MessageView.swift (VIEW COMPONENT)

**Rol:** Reusable UI Bileşeni

**Teknik Özellikler:**

```swift
struct MessageView: View {
    let message: Message
    
    var body: some View {
        // Conditional rendering
        HStack {
            if message.isUser { Spacer() }
            messageContent
            if !message.isUser { Spacer() }
        }
    }
}
```

**Conditional Styling:**
```swift
// WhatsApp benzeri tasarım
User mesajı:  [            📱 Mavi baloncuk]
AI mesajı:    [🤖 Gri baloncuk            ]
```

## 🔄 Data Flow (Veri Akışı)

### 1. Mesaj Gönderme Akışı

```
┌──────────────┐
│     USER     │
└──────┬───────┘
       │ 1. Tap "Gönder"
       ▼
┌─────────────────────────────────────┐
│          ChatView                   │
│  Button(action: viewModel.send)     │
└──────┬──────────────────────────────┘
       │ 2. Function call
       ▼
┌─────────────────────────────────────┐
│        ChatViewModel                │
│  func sendMessage() {               │
│    messages.append(userMsg)         │◄─── 3. Local update
│    Task {                           │
│      let response = await service() │──── 4. Async call
│      messages.append(aiMsg)         │◄─── 7. Update state
│    }                                │
│  }                                  │
└──────┬──────────────────────────────┘
       │ 5. Network request
       ▼
┌─────────────────────────────────────┐
│       OpenAIService                 │
│  func sendMessage() async throws    │
│  {                                  │
│    let request = buildRequest()     │──── 6. HTTP POST
│    let (data, _) = await fetch()    │
│    return parseResponse(data)       │
│  }                                  │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│        OpenAI API                   │
│   https://api.openai.com            │
└─────────────────────────────────────┘

       │
       │ 8. @Published trigger
       ▼
┌─────────────────────────────────────┐
│         SwiftUI                     │
│  observes @Published change         │
│  calls body again                   │
│  re-renders UI                      │
└─────────────────────────────────────┘
```

## ⚡ Performans Optimizasyonları

### 1. Lazy Loading
```swift
LazyVStack {
    ForEach(messages) { msg in
        MessageView(message: msg)
    }
}
// Sadece görünen view'lar render edilir
```

### 2. Value Types (Struct)
```swift
// Struct: Stack allocation → Hızlı
struct Message { ... }

// Class: Heap allocation → Yavaş + ARC overhead
class Message { ... }
```

### 3. Main Actor Isolation
```swift
@MainActor
class ChatViewModel: ObservableObject {
    // Tüm UI güncellemeleri main thread'de
}
```

### 4. Async/Await
```swift
// ❌ Eski yöntem (Pyramid of Doom):
service.fetch { result in
    process(result) { data in
        update(data) { success in
            // ...
        }
    }
}

// ✅ Modern yöntem:
let result = await service.fetch()
let data = await process(result)
await update(data)
```

## 🔐 Güvenlik Konuları

### 1. API Key Yönetimi

**❌ Yanlış (Şu anki durum):**
```swift
private let apiKey = "sk-xxx..." // Hardcoded
```

**✅ Doğru (Production için):**
```swift
// 1. Config.plist
let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY")

// 2. Environment Variable
let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]

// 3. Keychain
let apiKey = KeychainManager.shared.get("openai_key")
```

### 2. HTTPS Zorunluluğu
```swift
// iOS App Transport Security (ATS)
// Sadece HTTPS bağlantılara izin verir
let apiURL = "https://api.openai.com" // ✅
let apiURL = "http://api.openai.com"  // ❌ Engellenir
```

## 🧪 Test Stratejisi

### 1. Unit Tests

```swift
class ChatViewModelTests: XCTestCase {
    func testSendMessage() async throws {
        // Mock service ile test
        let mockService = MockOpenAIService()
        let viewModel = ChatViewModel(service: mockService)
        
        await viewModel.sendMessage()
        
        XCTAssertEqual(viewModel.messages.count, 2) // User + AI
    }
}
```

### 2. UI Tests

```swift
func testChatFlow() {
    let app = XCUIApplication()
    app.launch()
    
    let textField = app.textFields["Mesajınızı yazın..."]
    textField.tap()
    textField.typeText("Merhaba")
    
    app.buttons["Gönder"].tap()
    
    XCTAssertTrue(app.staticTexts["Merhaba"].exists)
}
```

## 📊 Bellek Yönetimi

### 1. ARC (Automatic Reference Counting)

```swift
// Class instance'ları için:
class ChatViewModel {
    let service = OpenAIService.shared // Strong reference
    weak var delegate: ChatDelegate?   // Weak reference (retain cycle önleme)
}
```

### 2. Value vs Reference Types

```swift
// Value Type (Struct) - Kopyalanır
var msg1 = Message(text: "Hi", isUser: true)
var msg2 = msg1  // Kopyalandı
msg2.text = "Hello" // msg1 etkilenmez

// Reference Type (Class) - Referans paylaşılır
var vm1 = ChatViewModel()
var vm2 = vm1  // Aynı instance
vm2.sendMessage() // vm1'de de görülür
```

## 🚀 Gelecek İyileştirmeler

### 1. Protocol-Oriented Programming

```swift
protocol ChatServiceProtocol {
    func sendMessage(messages: [Message]) async throws -> String
}

class OpenAIService: ChatServiceProtocol { ... }
class MockChatService: ChatServiceProtocol { ... }

// Dependency Injection
class ChatViewModel {
    init(service: ChatServiceProtocol) { ... }
}
```

### 2. Coordinator Pattern (Navigation)

```swift
class ChatCoordinator {
    func showSettings() { ... }
    func showHistory() { ... }
}
```

### 3. Repository Pattern (Data Persistence)

```swift
protocol MessageRepository {
    func save(_ messages: [Message]) async throws
    func fetch() async throws -> [Message]
}

class CoreDataMessageRepository: MessageRepository { ... }
```

## 📈 Ölçeklenebilirlik

Bu mimari, proje büyüdükçe kolayca genişletilebilir:

1. **Yeni Feature:** Yeni ViewModel + View ekle
2. **Yeni API:** Yeni Service ekle
3. **Yeni Model:** Models klasörüne ekle
4. **Yeni UI Component:** Views klasörüne ekle

Her katman bağımsız → Modüler geliştirme

---

**Bu doküman, projenin teknik altyapısını anlamak ve genişletmek için hazırlanmıştır.**

*Mühendislik perspektifiyle tasarlanmış, production-ready bir iOS uygulaması mimarisi.*
