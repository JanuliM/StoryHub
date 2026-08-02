# StoryHub 📖

StoryHub is a premium, beautifully crafted mobile application for sharing and reading stories. The application is built with a cross-platform Flutter frontend and a secure Node.js, Express, and Mongoose (MongoDB) backend service.

---

## Project Structure 📁

```text
StoryHub/
│
├── lib/                     # Flutter Frontend Applications
│   ├── models/              # Story and User domain models
│   ├── screens/             # UI Screens (HomeScreen, etc.)
│   ├── services/            # API Connection Services
│   ├── widgets/             # Reusable UI component widgets
│   └── main.dart            # Flutter app entry point
│
├── server/                  # Node.js + Express Backend
│   ├── middleware/          # Protected route authorization handlers
│   ├── models/              # MongoDB Schemas (User, Story)
│   ├── .env                 # Port & DB connection strings
│   ├── index.js             # Main server setup & Express routers
│   └── package.json         # Node.js project configuration
│
├── pubspec.yaml             # Flutter dependencies (http, etc.)
└── README.md                # Setup instructions
```

---

## Backend Setup & Run Guide 🖥️

### Prerequisites
* **Node.js** (v16+)
* **MongoDB** (Running locally on default port `27017` or configured via remote URI)

### Setup Instructions
1. Navigate to the `server/` directory:
   ```bash
   cd server
   ```
2. Install npm dependencies:
   ```bash
   npm install
   ```
3. Configure environment variables in `server/.env`:
   ```env
   PORT=5000
   MONGODB_URI=mongodb://localhost:27017/storyhub
   JWT_SECRET=supersecretstoryhubkey12345
   ```
4. Start the server:
   * **Development (auto-reload)**:
     ```bash
     npm run dev
     ```
   * **Production**:
     ```bash
     npm start
     ```
   *The console should output: `Successfully connected to MongoDB` & `Server started on port 5000`.*

### Available Endpoints
* `POST /register` - Registers a new user. Expects JSON: `{ "username": "...", "email": "...", "password": "..." }`. Returns user data and JWT token.
* `POST /login` - Log in user. Expects JSON: `{ "email": "...", "password": "..." }`. Returns user data and JWT token.
* `GET /stories` - Retrieves all stories in reverse chronological order (Public).
* `POST /stories` - Creates a new story. Requires authentication header: `Authorization: Bearer <TOKEN>`. Expects JSON: `{ "title": "...", "content": "...", "readTime": "..." }`.

---

## Frontend Setup & Run Guide 📱

### Prerequisites
* **Flutter SDK** installed and configured in your path.
* An active emulator, simulator, or connected physical device.

### Setup Instructions
1. Get packages:
   ```bash
   flutter pub get
   ```
2. Run the application:
   ```bash
   flutter run
   ```

### Emulator and Network Connection Details
* When running on an **Android Emulator**, the app is configured to hit the backend at `http://10.0.2.2:5000`.
* When running on an **iOS Simulator** or **Web**, the app is configured to hit `http://localhost:5000`.
* Customize the base URL directly in [`lib/services/api_service.dart`](file:///d:/StoryHub/lib/services/api_service.dart) if connecting to a production address or custom local IP.
