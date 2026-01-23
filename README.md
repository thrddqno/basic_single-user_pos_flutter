# Basic POS

## Overview

Basic Single User POS is an offline, single-device, single-user point-of-sale (POS) system designed for small businesses.
The primary goal is to enable daily sales operations without requiring an internet connection, while still providing reliable daily reporting and basic data analytics to support standard operating procedures (SOPs).

This project is intended for real-world use in a small family business environment, prioritizing reliability, simplicity, and clarity over advanced features.

## Project Goals

- Enable daily sales transactions on a single device
- Operate fully offline
- Provide clear daily sales reporting
- Store data locally and safely
- Keep the system simple and easy to use for non-technical users

## How it's made:

Techstack: Flutter, Dart, SQLite through SQLFlite

## Features

The MVP of the project includes the core features:

### Product Management

- Add, edit and customize products
- Manage product pricing and basic details

### Point-of-Sale Interface

- Simple POS Screen for creating sales
- Add/remove items from a cart
- Calculate totals and sale logic

### Sales & Transactions

- Record completed sales
- Store transaction data locally through databases and repositories

### Basic Data Analytics

- View sale summaries accurately by general, product, and categories within a selected date range

## Nice-to-have Features

These feature are not require for MVP completion but may be added later:

#### CSV Export

- Export daily or ranged sales data for record keeping

#### Online Sync

- Although this POS is operational offline, sync local data to a server when an internet connection is available

#### Inventory Management

- Track inventory management per recipe per item
