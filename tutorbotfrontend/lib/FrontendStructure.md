
## **1. Component & Widget Hierarchy**

This section details how widgets are nested to build the application's UI.

### **A. Root Structure (main.dart)**

```
TutorBotApp
└── MultiProvider
    ├── ThemeProvider
    ├── ProfileProvider
    └── MessageProvider
        └── MaterialApp
            └── AppInitializer (FutureBuilder)
                ├── OnboardingFlow (if no profile)
                └── MainInterface (if profile exists)
```

---

### **B. MainInterface Hierarchy (main_interface.dart)**

```
MainInterface
└── Scaffold
    ├── IndexedStack (body, switches between views)
    │   ├── [0] TutoringView
    │   ├── [1] PracticeZone
    │   ├── [2] BadgesView
    │   └── [3] ProgressDashboard
    └── BottomNavigationBar
```

---

### **C. TutoringView Hierarchy (tutoring_view.dart)**

This is the most complex view, managing three distinct UI modes.

```
TutoringView
└── Scaffold
    └── Column
        ├── Mode Selector (Row of 3 buttons)
        │
        ├── Content Area (Expanded)
        │   └── [Conditional Widget based on ChatMode]
        │       ├── ChatHistory (if text mode)
        │       │   └── ListView
        │       │       └── MessageBubble
        │       │           ├── StreamingText (for AI responses)
        │       │           └── HintsSection (expandable hints)
        │       │
        │       ├── VoiceInterfaceAdvanced (if voice mode)
        │       │   └── Column
        │       │       ├── Transcription Box
        │       │       ├── Animated Sound Bars
        │       │       └── Listening Controls
        │       │
        │       └── CameraInterface (if camera mode)
        │           └── Column
        │               ├── Capture View (buttons)
        │               └── Preview View (image + text field)
        │
        ├── Loading Indicator (overlay)
        │
        └── Text Input Area (if text mode)
```

---

## **2. File & Folder Organization**

The project follows a standard feature-first/layered architecture.

```
lib/
├── main.dart                          # App entry point, providers, routing
│
├── models/                            # Data structures (POCOs)
│   ├── learning_profile.dart         # User profile, enums (Grade, Subject)
│   ├── message.dart                  # Chat message object
│   └── practice_question.dart        # Practice quiz object
│
├── providers/                         # State management (using Provider)
│   ├── profile_provider.dart         # Manages user profile data
│   ├── message_provider.dart         # Manages chat history per subject
│   └── theme_provider.dart           # Manages light/dark mode
│
├── views/                             # Top-level screens/pages
│   ├── onboarding_flow.dart          # Multi-step user setup
│   ├── main_interface.dart           # Container with bottom navigation
│   ├── tutoring_view.dart            # Core chat/voice/camera screen
│   ├── practice_zone.dart            # Quiz/practice interface
│   ├── badges_view.dart              # Gamification/rewards screen
│   ├── progress_dashboard.dart       # User stats and settings
│   └── study_plan_view.dart          # (Not in use) For future study goals
│
├── widgets/                           # Reusable UI components
│   ├── chat_history.dart             # Renders the list of messages
│   ├── voice_interface_advanced.dart # Full voice-to-text component
│   ├── camera_interface.dart         # Image capture/preview component
│   ├── streaming_text.dart           # Typewriter effect for text
│   ├── typing_indicator.dart         # "..." animation for tutor responses
│   └── ... (selectors, indicators, etc.)
│
├── utils/                             # Helper classes & business logic
│   ├── tutor_engine.dart             # MOCK: Generates fake AI responses
│   ├── practice_generator.dart       # MOCK: Generates fake practice questions
│   ├── topic_data.dart               # Static data for topic suggestions
│   └── platform_utils.dart           # Platform detection helpers
│
└── theme/                             # App styling
    └── app_theme.dart                # Colors, fonts, button styles, etc.

test/
├── widget_test.dart                   # Basic widget tests
└── platform_test.dart                 # Platform-specific rendering tests
```

---

## **3. Navigation & Data Flow**

This section explains how users move through the app and how data is managed.

### **A. User Navigation Flow**

```
App Launch
    ↓
AppInitializer
    ↓
[Loads profile from SharedPreferences]
    │
    ├─ (No Profile) → OnboardingFlow
    │       ↓
    │   [User completes 4 steps]
    │       ↓
    │   [Profile is saved]
    │       ↓
    └─ (Profile Exists) → MainInterface (defaults to Chat tab)
            │
            └─ [User taps Bottom Nav Bar] → Switches active view in IndexedStack
                │
                ├─ Chat Tab → TutoringView
                │   └─ [User taps Mode Selector] → Switches UI in TutoringView
                │
                ├─ Practice Tab → PracticeZone
                │
                ├─ Rewards Tab → BadgesView
                │
                └─ Profile Tab → ProgressDashboard
```

### **B. State Management & Data Flow**

The app uses the `provider` package for state management, centralizing business logic and decoupling it from the UI.

#### **Provider Overview:**

*   **`ProfileProvider`**:
    *   **Responsibilities**: Holds the `LearningProfile` object. Loads it from and saves it to `SharedPreferences`. Provides methods to update profile stats (e.g., `incrementQuestionsAsked`).
    *   **Scope**: Global. Accessed by almost all views.
*   **`MessageProvider`**:
    *   **Responsibilities**: Holds a `Map` of message lists, keyed by `Subject`. Manages adding, updating, and removing messages. Persists chat history to `SharedPreferences`.
    *   **Scope**: Global. Primarily used by `TutoringView` and `ChatHistory`.
*   **`ThemeProvider`**:
    *   **Responsibilities**: Holds the current `ThemeMode` (light/dark).
    *   **Scope**: Global. Used by `MaterialApp` to set the theme.

#### **Data Flow Example: Sending a Chat Message**

1.  **User Input**: User types in the `TextField` in `TutoringView` and taps the send button.
2.  **Widget Event**: The `onPressed` callback in `TutoringView` calls the `_sendMessage` method.
3.  **State Update (User Message)**:
    *   `_sendMessage` creates a `Message` object with `role: MessageRole.student`.
    *   It calls `context.read<MessageProvider>().addMessage(...)`.
    *   `MessageProvider` adds the message to its internal list and calls `notifyListeners()`.
4.  **UI Rebuild**: `ChatHistory` (which is listening via `context.watch`) rebuilds, displaying the new student message.
5.  **State Update (Tutor Response)**:
    *   `_sendMessage` adds a temporary "typing indicator" message to `MessageProvider`.
    *   It calls the (mock) `TutorEngine.generateResponse()`.
    *   The typing indicator is removed.
    *   A new `Message` object (`role: MessageRole.tutor`, `isStreaming: true`) is added to `MessageProvider`.
6.  **UI Rebuild (Streaming)**: `ChatHistory` rebuilds. The `MessageBubble` sees `isStreaming: true` and uses the `StreamingText` widget to display the response with a typewriter effect.
7.  **Final State Update**: After the streaming animation completes, `_sendMessage` updates the tutor's message in `MessageProvider` to add hints (`message.copyWith(hints: ...)`).
8.  **Final UI Rebuild**: `ChatHistory` rebuilds one last time to show the newly available "Hints" section below the tutor's message.

This entire flow ensures that the UI is always a direct reflection of the state held in the providers, and all data is persisted locally for a seamless user experience across sessions.