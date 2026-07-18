# Suhbat 💬

A real-time group chat application built with Flutter and Supabase, created as a portfolio project.

> 🚧 This project is currently under active development.

## Screenshots


<p float="left">
    <img src="assets/img_register.png" alt="Register Screen" width="200"/>
    <img src="assets/img_login.png" alt="Login Screen" width="200"/>
    <img src="assets/img_chat.png" alt="Chat Screen" width="200"/>
    <img src="assets/img_edit_profile.png" alt="Profile Screen" width="200"/>
    <img src="assets/img_rooms.png" alt="Chat Room Screen" width="200"/>
</p>



## Features

- 🔐 Email authentication with OTP verification
- 💬 Real-time group messaging
- 👥 Create and join chat rooms
- 👤 User profiles with avatar initials
- ✅ Read receipts
- 📅 Date separators between messages
- 💬 Direct messaging (DM)
- 🔍 Search rooms and users
- 🔔 In-app notifications
- 🚪 Join/leave rooms
## Tech Stack

| Technology | Usage |
|------------|-------|
| Flutter | UI framework |
| Supabase | Backend, Auth, Realtime DB |
| Riverpod | State management |
| go_router | Navigation |
| flutter_local_notifications | In-app notifications |

## Getting Started

1. Clone the repo
```bash
git clone https://github.com/mukhammademineminov/suhbat.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Create `.env` file in root:

SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

4. Run the app
```bash
flutter run
```

## Database Setup

1. Create a new Supabase project
2. Go to SQL Editor → New query
3. Paste the contents of `schema.sql` and run it
4. Enable Realtime for `messages`, `direct_messages`, and `conversations` tables (Table Editor → table → Realtime toggle)
5. Copy your project URL and anon key into `.env`

## Author

**Mukhammademin** — Flutter Developer
[LinkedIn](https://www.linkedin.com/in/mukhammademin-eminov-00b977266?utm_source=share_via&utm_content=profile&utm_medium=member_ios) · [GitHub](https://github.com/mukhammademineminov)