# Flutter Multi-Payment Integration

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Stripe](https://img.shields.io/badge/Stripe-626CD9?style=for-the-badge&logo=Stripe&logoColor=white)
![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)
![PayMob](https://img.shields.io/badge/PayMob-ED1C24?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBkPSJNMTIgMkM2LjQ3NyAyIDIgNi40NzcgMiAxMnM0LjQ3NyAxMCAxMCAxMCAxMC00LjQ3NyAxMC0xMFMxNy41MjMgMiAxMiAyem0xLjQ0OCAxNC4xMjVoLTIuODk2di00LjM5NWgyLjg5NnY0LjM5NXptNC45OTQtNi40MDZoLTRWMTIuODJoMS45OTd2LTEuMUgxNC40NDJWNy43MTloNC4wMDN2MS4wMDFoLTIuMDA3djEuOTk5aDIuMDA0djEuMDAxek03LjU1OCA3LjcxOWgyLjAxN3YyLjQwMWgyLjM2OXYtMi40MDFoMi4wMDZ2Ni40MDZoLTIuMDA2di0yLjk5OUg5LjU3NXYyLjk5OUg3LjU1OFY3LjcxOXoiIGZpbGw9IndoaXRlIj48L3BhdGg+PC9zdmc+&logoColor=white)

## 📝 Overview

A comprehensive Flutter payment processing application that integrates three of the most popular payment gateways: **Stripe**, **PayPal**, and **PayMob**. What makes this project unique is the implementation of each payment method in two different ways:

1. **Native Implementation**: Direct integration with the payment gateways' APIs without relying on third-party packages, providing complete control and deep understanding of how each gateway works.

2. **Package-based Implementation**: Integration using official packages for a more streamlined development experience.

## ✨ Features

### Multiple Payment Gateways
- **Stripe**: International payment processing with support for credit cards
- **PayPal**: Global digital wallet and online payments
- **PayMob**: Middle Eastern payment solution with local payment methods

### Payment Methods
- Credit/Debit Card processing
- Digital wallets integration
- Mobile wallet support (for PayMob)
- Kiosk support (for PayMob)

### Implementation Options
- **Native API Integration**
  - Direct HTTP requests to payment gateways
  - Custom error handling and state management
  - Full control over the payment flow

- **Package-based Integration**
  - Simplified implementation using official SDKs
  - Faster development with pre-built UI components
  - Streamlined authentication and token management

## 🔧 Technical Details

- Built with **Flutter** for cross-platform compatibility
- Clean architecture with separation of concerns
- Comprehensive error handling
- Environment configuration for development and production
- Secure API key management

## 🚀 Getting Started

1. Clone the repository
```bash
git clone https://github.com/shahbbo/multi_payment_gateway
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure your API keys in the `.env` file
```
STRIPE_PUBLISHABLE_KEY=pk_test_your_key
STRIPE_SECRET_KEY=sk_test_your_key
PAYPAL_CLIENT_ID=your_client_id
PAYPAL_SECRET=your_secret
PAYMOB_API_KEY=your_api_key
```

4. Run the application
```bash
flutter run
```

## 👨‍💻 Author

**shahbbo** - [GitHub Profile](https://github.com/shahbbo)

## 📅 Last updated

2025-05-23

---

⭐ If you find this project helpful, please consider giving it a star on GitHub!
