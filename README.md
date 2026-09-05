# 🎀 Velora

### Beauty & Cosmetics E-Commerce Mobile Application

Velora is a modern beauty and cosmetics e-commerce mobile application built with **Flutter and Firebase**.

The application provides a smooth shopping experience for users while giving administrators full control over products, categories, and orders.

The project was developed with a focus on **clean UI, organized architecture, Firebase integration, real-time data handling, stock management, and role-based access**.

---

## ✨ Features

### 👩🏻 User Features

* 🔐 User Registration & Login
* 👤 Profile Management
* 🖼️ Profile Image Upload
* 🛍️ Browse Beauty & Skincare Products
* 📄 Product Details
* ❤️ Add & Remove Favorites
* 🛒 Add Products to Cart
* ➕ Increase Product Quantity
* ➖ Decrease Product Quantity
* 📦 Stock Availability Validation
* 💰 Automatic Subtotal Calculation
* 📍 Delivery Address Management
* 🧾 Checkout
* 📋 View My Orders
* 🚚 Order Status Tracking
* 🔓 Logout

### 👩🏻‍💼 Admin Features

* 📊 Admin Dashboard
* 📦 Product Management
* ➕ Add Products
* ✏️ Edit Products
* 🗑️ Delete Products
* 🖼️ Product Image Upload
* 🏷️ Category Management
* 📋 Order Management
* 🔄 Update Order Status
* 📈 Store Statistics

---

# 📱 Screenshots

## 👩🏻 User App

### Onboarding & Authentication

<p align="center">
  <img src="screenshots/onboarding.png" width="250"/>
  <img src="screenshots/login.png" width="250"/>
  <img src="screenshots/signup.png" width="250"/>
</p>

### Home & Products

<p align="center">
  <img src="screenshots/home.png" width="250"/>
  <img src="screenshots/product_details.png" width="250"/>
</p>

### Favorites & Cart

<p align="center">
  <img src="screenshots/favorites.png" width="250"/>
  <img src="screenshots/cart.png" width="250"/>
</p>

### Checkout & Orders

<p align="center">
  <img src="screenshots/address.png" width="250"/>
  <img src="screenshots/checkout.png" width="250"/>
  <img src="screenshots/orders.png" width="250"/>
</p>

### Profile

<p align="center">
  <img src="screenshots/profile.png" width="250"/>
</p>

---

## 👩🏻‍💼 Admin App

### Dashboard & Products

<p align="center">
  <img src="screenshots/admin_dashboard.png" width="250"/>
  <img src="screenshots/admin_products.png" width="250"/>
</p>

### Categories & Orders

<p align="center">
  <img src="screenshots/categories.png" width="250"/>
  <img src="screenshots/admin_orders.png" width="250"/>
</p>

### Product Management

<p align="center">
  <img src="screenshots/add_product.png" width="250"/>
  <img src="screenshots/edit_product.png" width="250"/>
</p>

---

# 🛠️ Technologies & Tools

| Technology                  | Usage                          |
| --------------------------- | ------------------------------ |
| **Flutter**                 | Mobile application development |
| **Dart**                    | Programming language           |
| **Firebase Authentication** | User authentication            |
| **Cloud Firestore**         | Application data & orders      |
| **Firebase Storage**        | Product & profile images       |
| **Provider**                | State management               |
| **SharedPreferences**       | Local storage                  |
| **Image Picker**            | Selecting images from device   |

---

# 🏗️ Project Architecture

The project is organized into separate layers to keep the code clean and easier to maintain.

```text
lib/
│
├── controllers/
│   ├── auth_controller.dart
│   ├── home_controller.dart
│   ├── onboarding_controller.dart
│   └── profile_controller.dart
│
├── core/
│   └── constants/
│       ├── app_colors.dart
│       └── app_sizes.dart
│
├── features/
│   ├── admin/
│   │   └── screens/
│   │
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   │
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   │
│   ├── profile/
│   │   └── profile_screen.dart
│   │
│   ├── splash/
│   │   └── app_start_screen.dart
│   │
│   └── user/
│       ├── address/
│       ├── cart/
│       ├── checkout/
│       ├── favorites/
│       ├── home/
│       ├── orders/
│       └── product/
│
├── models/
│   ├── address_model.dart
│   ├── beauty_product_model.dart
│   ├── cart_model.dart
│   ├── onboarding_model.dart
│   ├── order_model.dart
│   ├── product_model.dart
│   └── profile_model.dart
│
├── services/
│   ├── address_service.dart
│   ├── auth_service.dart
│   ├── cart_service.dart
│   ├── favorites_service.dart
│   ├── order_service.dart
│   ├── preferences_service.dart
│   ├── product_service.dart
│   └── profile_service.dart
│
├── widgets/
│   ├── beauty_button.dart
│   ├── custom_text_field.dart
│   └── product_card.dart
│
├── auth_gate.dart
├── firebase_options.dart
└── main.dart
```

---

# 🔥 Firebase Integration

Velora uses Firebase as the main backend infrastructure.

### Firebase Authentication

Authentication is implemented using **Firebase Authentication with Email & Password**.

The application also uses user roles to determine which interface should be displayed.

```text
User Login
     ↓
Firebase Authentication
     ↓
Get User UID
     ↓
Check User Role
     ↓
 ┌──────────────┐
 │              │
 User         Admin
 ↓              ↓
User App     Admin App
```

---

# 🗄️ Firestore Structure

The main Firestore collections are organized as follows:

```text
users/
   └── {uid}
       ├── name
       ├── age
       ├── phone
       ├── bio
       ├── imageUrl
       ├── role
       └── createdAt

products/
   └── {productId}
       ├── name
       ├── price
       ├── description
       ├── category
       ├── quantity
       ├── imageUrl
       ├── createdAt
       └── createdBy

categories/
   └── {categoryId}

orders/
   └── {orderId}
       ├── userId
       ├── userEmail
       ├── userName
       ├── userPhone
       ├── items
       ├── total
       ├── status
       ├── createdAt
       └── updatedAt

users/{uid}/cart/
   └── {productId}

users/{uid}/favorites/
   └── {productId}
```

---

# 🛒 Cart Logic

The Cart is stored separately for every authenticated user.

```text
users/{uid}/cart
```

Each cart item contains product information, selected quantity, and available stock.

The application calculates the subtotal using:

```text
Subtotal = Product Price × Quantity
```

The total cart value is calculated by adding the subtotal of all cart items.

### Stock Validation

The application prevents users from selecting a quantity greater than the available stock.

The validation is handled inside the Cart Service, not only in the UI.

This means the UI provides feedback to the user while the service is responsible for enforcing the business rule.

---

# ❤️ Favorites

Each user has their own favorites collection:

```text
users/{uid}/favorites
```

Users can add products to favorites or remove them.

The UI reflects changes immediately through the application's state management and data streams.

---

# 📦 Order Management

The checkout process creates an order containing the required user, product, quantity, and total information.

The order lifecycle includes:

```text
Cart
 ↓
Checkout
 ↓
Create Order
 ↓
Update Product Stock
 ↓
Clear Cart
 ↓
Order Created
```

Administrators can manage orders and update their status from the Admin Orders screen.

---

# 👩🏻‍💼 Role-Based Access

Velora supports two main roles:

```text
admin
user
```

After authentication, the application retrieves the user's role and navigates to the correct application area.

### User

Accesses:

* Home
* Products
* Favorites
* Cart
* Checkout
* Orders
* Profile

### Admin

Accesses:

* Dashboard
* Products
* Categories
* Orders
* Product Management

---

# 💾 Local Storage

`SharedPreferences` is used for lightweight local data.

In Velora, it is used to store the onboarding completion state:

```text
onboarding_completed
```

After completing onboarding, the application stores the value as `true`.

This allows the application to know whether the onboarding flow has already been completed.

---

# 🎨 UI / UX Design

Velora was designed with a soft and modern beauty-inspired visual identity.

The design focuses on:

* 🌸 Soft feminine colors
* 🤍 Clean backgrounds
* 🎀 Rounded cards
* ✨ Consistent spacing
* 🖼️ Product-focused layouts
* 🔤 Clear typography
* 📱 Responsive mobile layouts
* ♻️ Reusable UI components

The main visual direction uses soft pink, dusty rose, mauve, cream, and neutral tones to match the beauty and cosmetics theme.

---

# 🧠 Technical Decisions

### Why Firebase?

Firebase was selected because it provides the main backend services required by the application in one ecosystem, including authentication, database, and storage.

### Why Firestore?

Firestore provides structured cloud data storage for users, products, categories, carts, favorites, and orders.

### Why Provider?

Provider is used to manage application state in a simple and organized way, especially for controller-based UI updates.

### Why SharedPreferences?

SharedPreferences is suitable for small local flags and preferences, such as storing whether the onboarding process has been completed.

### Why Services?

Firebase operations are separated into service classes instead of being written directly inside screens.

For example:

```text
ProductScreen
      ↓
ProductService
      ↓
Firestore
```

This keeps the UI cleaner and makes the data layer easier to maintain.

---

# 🔄 Application Flow

```text
                ┌──────────────┐
                │  Onboarding  │
                └──────┬───────┘
                       ↓
                ┌──────────────┐
                │ Authentication│
                └──────┬───────┘
                       ↓
                 Role Detection
                       ↓
            ┌──────────┴──────────┐
            ↓                     ↓
          USER                  ADMIN
            ↓                     ↓
          Home                Dashboard
            ↓                     ↓
        Products             Products
            ↓                     ↓
          Cart                Categories
            ↓                     ↓
        Checkout               Orders
            ↓
          Order
```

---

# 📁 Main Code Responsibilities

### Models

Represent application data.

Examples:

```text
ProductModel
CartModel
OrderModel
ProfileModel
AddressModel
```

### Services

Handle Firebase and data-related operations.

Examples:

```text
ProductService
CartService
OrderService
ProfileService
FavoritesService
```

### Controllers

Handle UI-related state and interactions.

### Screens

Build the application's user interfaces.

### Widgets

Contain reusable UI components.

### Constants

Keep shared design values such as colors and sizes centralized.

---

# ▶️ Getting Started

## Prerequisites

Before running the project, make sure you have:

* Flutter SDK installed
* Dart SDK
* Android Studio or VS Code
* A Firebase project
* An emulator or physical device

## Installation

Clone the repository:

```bash
git clone YOUR_REPOSITORY_URL
```

Navigate to the project:

```bash
cd velora
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# 📦 Main Dependencies

The project uses several Flutter packages, including:

```yaml
firebase_core
firebase_auth
cloud_firestore
firebase_storage
image_picker
provider
shared_preferences
```

---

# 👥 Team Contributions

| Team Member | Main Responsibility                    |
| ----------- | -------------------------------------- |
| **Dima**    | Firebase Setup, Authentication & Roles |
| **Hiba**    | Product Flow & Favorites               |
| **Malak**   | Cart Logic & Local Storage             |
| **Dana**    | Checkout & Order Management            |

---

# 🎯 Project Goals

The main goals of Velora were to:

* Build a complete Flutter e-commerce application.
* Practice Firebase Authentication.
* Work with Cloud Firestore.
* Upload and manage images using Firebase Storage.
* Implement role-based application flows.
* Practice state management using Provider.
* Build a complete shopping cart.
* Handle product stock correctly.
* Implement checkout and order management.
* Organize the application using reusable services, models, controllers, and widgets.
* Create a clean and consistent user experience.

---

# 🚀 Future Improvements

Possible future improvements include:

* 💳 Online payment integration
* 🔔 Push notifications
* ⭐ Product ratings and reviews
* 🎁 Discount and coupon system
* 🔍 Advanced product filtering
* 🌙 Dark mode
* 📊 More advanced analytics
* 🎁 Wishlist improvements
* 📱 Additional responsive layouts

---

# 💗 Velora

**Velora — Beauty & Cosmetics E-Commerce Application**

Built with:

**Flutter • Dart • Firebase • Firestore • Firebase Storage • Provider**

---

### 👩🏻‍💻 Developed as part of Flutter Training

A project focused on combining **UI/UX design, Flutter development, Firebase integration, state management, and real-world e-commerce logic**.
