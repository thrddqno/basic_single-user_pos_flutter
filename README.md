<a id="readme-top"></a>

[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![Unlicense License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]


<br />
<div align="center">

  <h1 align="center">basic_single-user_pos_flutter</h1>

  <p align="center">
    A single-device, single-user point-of-sale (POS) system with offline capabilities and basic data analytics, designed for small businesses to manage daily sales and reporting without relying on an internet connection.
    <br />
    <br />
    <a href="https://github.com/thrddqno/basic_single-user_pos_flutter/releases">Get Latest Release</a>
    |
    <a href="https://github.com/thrddqno/basic_single-user_pos_flutter/issues/new?labels=bug&template=bug-report---.md">Report Issue</a>
    |
    <a href="https://github.com/thrddqno/basic_single-user_pos_flutter/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#key-goals">Key Goals</a></li>
        <li><a href="#techstack">Techstack</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#usage">Usage</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

## About The Project

**basic_single-user_pos_flutter** is a single-device, single-user point-of-sale (POS) system built with Flutter. It works completely offline, stores data locally using SQLite, and provides basic analytics to help small businesses track daily sales.

**This project was inspired by a real need:** my parents run a small ice cream store, and we faced trust and record-keeping issues with daily ledgers and sales reports, and listing them manually on paper was a nuisance to our crew. Existing POS solutions were mostly cloud-based, which didn’t suit our small-scale offline needs. I couldn’t find an offline-first POS with built-in analytics, so I challenged myself to build one using my skills.

### Key Goals:
- Enable daily sales on a single device without internet
- Manage products, modifiers, and pricing
- Record transactions and generate basic sales reports
- Keep data secure and local
- Simple and clean UI for non-technical users

### Techstack:
[![Flutter][flutter-shield]][flutter-url]
[![Dart][dart-shield]][dart-url]
[![SQFlite][sqflite-shield]][sqflite-url]

## Getting Started
### Prerequisites
- Flutter SDK Installed
- Compatible device or emulator (Android Studio)

### Installation
**1. Clone the repo**
```bash
git clone https://github.com/thrddqno/basic_single-user_pos_flutter.git
cd basic_single-user_pos_flutter
```
**2. Install Dependencies**
```bash
flutter pub get
```
**3. Run on a device/emulator**
```bash
flutter run
```

### Usage
1. Launch the app
2. Add products, categories, and configure modifiers
3. Process sales and add items to the cart
4. Access analytics to view daily sales summaries

## Roadmap
*For current goals and alignment:*
- [x] **Backend functionality**
- [x] **Product & Modifier management**
- [ ] Sale Transactions & Checkout
- [ ] Receipt Management
- [ ] DateRange Analytics

## License

Distributed under the project_license. See `LICENSE.txt` for more information.

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[forks-shield]: https://img.shields.io/github/forks/thrddqno/basic_single-user_pos_flutter.svg?style=for-the-badge
[forks-url]: https://github.com/thrddqno/basic_single-user_pos_flutter/network/members
[stars-shield]: https://img.shields.io/github/stars/thrddqno/basic_single-user_pos_flutter.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/thrddqno/basic_single-user_pos_flutter.svg?style=for-the-badge
[issues-url]: https://github.com/thrddqno/basic_single-user_pos_flutter/issues
[license-shield]: https://img.shields.io/github/license/thrddqno/basic_single-user_pos_flutter.svg?style=for-the-badge
[license-url]: https://github.com/thrddqno/basic_single-user_pos_flutter/blob/main/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/thrddqno
[flutter-shield]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[flutter-url]: https://flutter.dev/
[dart-shield]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[dart-url]: https://dart.dev/
[sqflite-shield]: https://img.shields.io/badge/sqflite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white
[sqflite-url]: https://pub.dev/packages/sqflite
