# 🏆 Tournament App (Flutter)

A cross-platform mobile application for viewing tournaments, live matches, and real-time scores.
Built using Flutter with Firebase and backend API integration.

---

# 📱 Assignment Concept Explanation

## How Flutter’s Widget-Based Architecture Ensures Smooth Cross-Platform Performance

Flutter follows a widget-based architecture where everything in the UI is a widget — including text, buttons, layouts, and entire screens.

The UI is structured as a **widget tree**.
When the application state changes, Flutter rebuilds only the affected widgets instead of the entire screen.

This selective rebuilding ensures:

* ⚡ Faster rendering
* 🎯 Efficient UI updates
* 📱 Smooth performance on both Android and iOS

Flutter renders everything using its own rendering engine, ensuring consistent UI behavior across platforms.

---

## 🔄 StatelessWidget vs StatefulWidget (Used in This App)

### 🔹 StatelessWidget

Used for static UI components that do not change after being built.

Examples in this app:

* AppBar titles
* Static labels
* Tournament headers

Stateless widgets are lightweight and do not rebuild unless their parent rebuilds.

---

### 🔹 StatefulWidget

Used when UI changes dynamically based on user interaction or live data.

Examples in this app:

* Live score updates
* Match status changes
* Real-time data from Firebase

When state changes, `setState()` is called.
This tells Flutter to rebuild only that specific widget subtree.

Example:

```dart
void updateScore() {
  setState(() {
    score++;
  });
}
```

Only the score widget updates — not the entire screen.

This improves performance and keeps animations smooth.

---

# 📉 Case Study: “The Laggy To-Do App” Analysis

## Problem

The app feels sluggish because:

* Entire screen rebuilds on every update
* Deeply nested widgets
* Poor state management
* `setState()` called at top-level widgets unnecessarily

When large parent widgets rebuild, Flutter recalculates layout and rendering for many unnecessary components.

This causes:

* Dropped frames
* UI lag
* Poor performance on iOS

---

## ✅ Solution Using Proper State Management

To avoid lag:

* Move state closer to where it is needed
* Keep widgets small and modular
* Rebuild only dynamic sections (e.g., match score list)

In this Tournament App:

* Tournament list updates without rebuilding the entire page
* Live score widget updates independently
* Static UI elements remain unchanged

This ensures consistent 60fps performance.

---

# ⚡ Dart’s Reactive & Async Model

Dart supports:

* Async/Await
* Event-driven programming
* Non-blocking UI updates
* Strong typing and null safety

Example:

```dart
Future<void> fetchMatches() async {
  final response = await apiService.getMatches();
  setState(() {
    matches = response;
  });
}
```

The UI remains responsive while data loads.

This helps maintain a smooth frame rate across Android and iOS.

---

# 🚀 Features

* View tournaments list
* Live match tracking
* Tournament details
* Real-time score updates
* Firebase authentication (planned)
* Backend API integration

---

# 🛠 Tech Stack

* Flutter (Dart)
* Firebase (Auth / Firestore)
* REST APIs (Spring Boot backend)
* Android Studio / VS Code

---

# 📁 Project Structure

```
lib/
│
├── main.dart
│
├── screens/        # App pages
├── widgets/        # Reusable UI components
├── services/       # API & Firebase logic
├── models/         # Data models
```

---

# ⚙️ Setup Instructions

1. Install Flutter SDK
2. Clone the repository
3. Run `flutter pub get`
4. Connect emulator/device
5. Run `flutter run`

---

# 👨‍💻 Developers

* **Pranav** — Backend
* **Sejal Jaiswal** — Frontend
* **Tanmya** — DevOps

---

# 🧠 Conclusion

Flutter ensures smooth cross-platform performance because:

* It rebuilds only necessary widgets
* It controls rendering using its own engine
* Dart enables reactive and async programming
* Proper state management prevents unnecessary rebuilds

By structuring widgets efficiently and managing state carefully, the Tournament App delivers smooth, responsive UI across platforms.
