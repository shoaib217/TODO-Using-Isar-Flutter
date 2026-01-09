# Isar Task Manager (CRUD) 🚀

A modern, high-performance Task Management application built with **Flutter** and the **Isar Database (v4.0.0-dev)**. This project features a reactive architecture, smooth custom animations, and a refined user interface.

## ✨ Key Features
- **Isar 4.0 NoSQL Database**: Ultra-fast local storage with reactive streams.
- **Advanced Task Schema**: Support for Titles, Categories (Work, Personal, Shopping), and Priority Levels (Low, Medium, High).
- **Smooth Animations**:
    - **List Animations**: Uses `AnimatedList` for sliding and fading items when added or removed.
    - **UI Motion**: Custom `TweenAnimationBuilder` in the Bottom Sheet for a springy "slide-up" entry effect.
- **Smart Sorting**: Automatic sorting logic that prioritizes high-priority tasks followed by the creation date.
- **Modern UI/UX**: Built with Material 3 design principles, including `ChoiceChips` for selection and a clean card-based layout.

## 🛠 Technical Solutions Implemented
During development, several critical modern Flutter/Android challenges were resolved:
1. **Isar 4.0 Migration**: Successfully migrated from v3 to v4, handling the removal of `isar_generator` and adapting to the new `Id` assignment logic.
2. **Gradle Namespace Fix**: Solved the `Namespace not specified` error for `isar_flutter_libs` by implementing a dynamic namespace assignment in the `build.gradle.kts` file.
3. **Internal BottomSheet State**: Utilized `StatefulBuilder` to allow real-time UI updates (chips and buttons) inside the Modal Bottom Sheet.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Dart SDK


## 📂 Project Structure
- `lib/todo.dart`: The Isar Collection model with custom fields.
- `lib/isar_service.dart`: The database service layer handling CRUD operations and reactive watchers.
- `lib/main.dart`: The UI layer featuring `AnimatedList`, `StreamBuilder`, and custom UI components.

## 📝 License
This project is open-source and available under the MIT License.

---
*Developed with ❤️ using Flutter and Isar.*