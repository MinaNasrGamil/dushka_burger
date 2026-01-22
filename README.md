
# DushkaBurger (Flutter) — Clean Architecture + Cubit

A production‑style Flutter implementation for DushkaBurger APIs using:
- Clean Architecture (Domain / Data / Presentation)
- Cubit (flutter_bloc)
- Dio networking + Basic Auth
- GetIt dependency injection
- EN/AR localization + RTL
- Guest flow (no login)

> Implemented screens: **Categories (Menu)**, **Product Details**, **Cart**.

---

## ✅ What’s Done (Quick Summary)
- Guest user flow: creates + caches `guest_id`
- Categories screen: chips + products list + add to cart
- Product details: variations + addons/extras + quantity + add to cart
- Cart: view items + totals + delete + qty controls
- Error handling (network / parsing / server) + retry states
- Skeleton loading + image fallbacks
- Localization EN/AR + RTL support

---

## 🧱 Architecture (Clean & Simple)

**Presentation**
- Cubits + UI pages
- UI reads state only

**Domain**
- Entities + UseCases
- Repositories contracts

**Data**
- Remote data sources (Dio)
- DTO models + mappers
- Repos implementation

DI via **GetIt** in `core/di/di.dart`.

---

## 🔌 API Setup

Base URL:
```text
https://dushkaburger.com/wp-json/
```

Auth:
- Basic Auth (wired through Dio interceptor)

> Note: Credentials are currently inside the project (task demo). In real apps, secrets should not live in the client.

---

## ▶️ How to Run

```bash
flutter pub get
flutter run
```
If localization generation fails:

flutter gen-l10n
flutter run

---

##🌍 Localization

English + Arabic supported
RTL works automatically when Arabic locale is active

---


## ⚠️ Known Backend Issue (Important)

There’s a backend pricing bug when:
- Item has **addons/extras**
- Quantity becomes **> 1**

Totals can become incorrect (looks like addons are multiplied twice).

### ✅ Workaround Implemented
- If addons selected: quantity is limited (UI prevents wrong totals)
- In Cart: quantity controls disabled for addon/custom items (delete only)
- User gets a clear message/snackbar explaining the limitation

This keeps the flow correct and avoids showing wrong pricing.

---

## 📸 Screenshots

Put screenshots in: `README_assets/`

Suggested names:
- `README_assets/menu_en.png`
- `README_assets/details_en.png`
- `README_assets/cart_en.png`
- `README_assets/menu_ar.png`
- `README_assets/details_ar.png`
- `README_assets/cart_ar.png`

GitHub will render them automatically:

### EN
![Menu EN](README_assets/menu_en.png)
![Details EN](README_assets/details_en.png)
![Cart EN](README_assets/cart_en.png)

### AR (RTL)
![Menu AR](README_assets/menu_ar.png)
![Details AR](README_assets/details_ar.png)
![Cart AR](README_assets/cart_ar.png)

---

## 🧪 Notes for Reviewers
- Guest ID is cached so cart works across app restarts.
- Addons options don’t include IDs from API, so the app generates stable IDs.
- UI states: loading / error / empty handled consistently.

---

## 📦 Tech Stack
- Flutter + Dart
- flutter_bloc (Cubit)
- Dio
- GetIt
- intl + gen-l10n
- skeletonizer (skeleton loading)

---

## 👤 Author
Mina Nasr
