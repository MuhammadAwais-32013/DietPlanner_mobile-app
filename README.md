# 🩺 DiaBp Diet Consultant - AI-Powered Health Assistant

A modern, full-stack web application that provides personalized diet plans and health recommendations using AI-powered RAG (Retrieval-Augmented Generation) technology. Built for diabetes and hypertension management with OCR-based medical document processing.

**Language Composition**: Python (56.6%) | Dart (43%) | Other (0.4%)

---

## 📚 Table of Contents
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [System Architecture](#-system-architecture)
- [Database Schema](#-database-schema)
- [Project Structure](#-detailed-project-structure)
- [API Endpoints](#-api-endpoints-specification)
- [Dependencies](#-dependencies-deep-dive)
- [Setup Guide](#-advanced-setup-guide)
- [Configuration](#-configuration)
- [Testing](#-testing-strategy)
- [Docker Deployment](#-docker-deployment)
- [Performance Optimization](#-performance-optimization)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Security](#-security-architecture)
- [Error Handling](#-error-handling--logging)
- [Troubleshooting](#-support--troubleshooting)
- [Contributing](#-contributing-guidelines)

---

## 🚀 Features

### 🤖 AI-Powered Diet Assistant
- **RAG-based Chatbot**: Intelligent responses grounded in medical literature
- **Personalized Diet Plans**: AI-generated meal plans for 7, 10, 14, 21, and 30 days
- **Medical Document Processing**: OCR extraction of medical data from PDFs and images
- **Professional PDF Export**: Download diet plans in professionally formatted PDFs
- **Context-Aware Responses**: Structured responses similar to ChatGPT interface

### 👤 User Management
- **Secure Authentication**: User registration and login with bcrypt password hashing
- **Session Persistence**: Token-based authentication with automatic cleanup
- **Health Profile Management**: Comprehensive health data tracking
- **BMI Calculator**: Automatic BMI calculation with health category classification
- **Medical Records**: Upload and track medical documents and lab results

### 📊 Health Tracking
- **Blood Pressure Monitoring**: Track systolic and diastolic readings
- **Blood Sugar Tracking**: Monitor glucose levels and HbA1c
- **Medical History**: Comprehensive health record management
- **Data Visualization**: Visual health metrics and trends
- **Health Analytics**: Admin dashboard with user health statistics

### 🎯 Diet Planning
- **Personalized Recommendations**: Based on diabetes type, blood pressure, and BMI
- **Nutritional Guidelines**: Evidence-based dietary recommendations
- **Lifestyle Recommendations**: Exercise and activity suggestions
- **Multi-Duration Plans**: Support for 1 week, 10 days, 2 weeks, 3 weeks, and 1 month
- **Professional Formatting**: Structured responses with clear sections and guidelines

### 🔧 Admin Features
- **User Management**: Comprehensive admin dashboard
- **Database Records**: View all user data in tabular format
- **Health Analytics**: Monitor user health trends and statistics
- **Data Export**: CSV export functionality for reports

---

## 🛠️ Tech Stack

<<<<<<< HEAD
### Frontend
- **Flutter** - Cross-platform UI framework
- **Dart** - Primary programming language for the frontend
- **Provider / Riverpod** - State management
- **Dio** - HTTP client for API requests
- **GoRouter** - Declarative routing
=======
### Frontend (43% Dart/JavaScript)
- **Framework**: Next.js 13.4.19 (React framework with SSR)
- **UI Framework**: React 18.2.0 with React Hooks
- **State Management**: React Context API for global state
- **Styling**: Tailwind CSS 3.3.3 (Utility-first CSS)
- **PDF Generation**: jsPDF 2.5.1 (Client-side PDF export)
- **HTTP Client**: Axios 1.9.0 (API communication)
- **Date Picker**: react-datepicker 4.16.0 (Health tracking dates)
- **Real-time**: WebSocket integration for live chat
- **Build Tools**: PostCSS, Autoprefixer, ESLint
>>>>>>> 4634baa02a1089327db956ddc1e17e06fd914004

### Backend (56.6% Python)
- **Framework**: FastAPI (Modern async Python web framework)
- **Server**: Uvicorn (ASGI server)
- **Database ORM**: SQLAlchemy 2.0.4
- **Database**: SQLite (Lightweight, file-based)
- **Authentication**: bcrypt 4.0.1 (Password hashing)
- **Real-time**: WebSocket for bidirectional communication
- **File Upload**: python-multipart (Form data handling)
- **Environment**: python-dotenv 1.0.0

### AI & ML Stack
- **LLM**: Google Gemini API (gemini-2.5-flash-lite model)
- **Embeddings**: Sentence Transformers (all-MiniLM-L6-v2 model)
- **Vector Search**: FAISS CPU (Facebook AI Similarity Search)
- **Document Processing**: 
  - PyMuPDF (PDF text extraction and parsing)
  - pdfplumber (Advanced PDF table extraction)
  - Tesseract OCR (Image to text conversion)
  - Pillow (Image processing)
- **RAG Framework**: LLaMA Index (Document indexing and retrieval)
- **Utilities**: tqdm (Progress bars)

<<<<<<< HEAD
### RAG System
- **Knowledge Base**: Medical literature and guidelines
- **Vector Search**: Semantic document retrieval
- **Context-Aware Responses**: Grounded in scientific literature

*Note: To add more data:*
```bash
uv run batch_ingest.py --pdf_dir data --output_dir faiss
```
## 📁 Project Structure

```
DietPlanner_mobile/
├── 📁 diabp_mobile/          # Flutter Frontend application
│   ├── android/              # Android-specific files
│   ├── ios/                  # iOS-specific files
│   ├── lib/                  # Dart UI code and logic
│   │   ├── core/             # Themes, constants, networking
│   │   ├── screens/          # Application screens
│   │   ├── services/         # API integrations
│   │   └── widgets/          # Reusable UI components
│   └── pubspec.yaml          # Flutter dependencies
│
├── 📁 backend/               # FastAPI Backend
│   ├── api/                  # API endpoints
│   ├── ChatBot/              # RAG system core
│   │   ├── data/             # Knowledge base and uploads
│   │   ├── models/           # ML models
│   │   ├── gemini_llm.py     # LLM integration
│   │   ├── retriever.py      # RAG retrieval
│   │   ├── ocr_parser.py     # Medical data extraction
│   │   └── knowledge_base.py # PDF processing
│   ├── instance/             # Database files
│   ├── exports/              # Data exports
│   └── tests/                # Test files
│
└── 📁 Documentation
    ├── docs/                 # Project documentation
    └── README.md             # This file
=======
### Testing & Quality
- **Testing**: pytest, pytest-asyncio (Async test support)
- **HTTP Testing**: httpx (Async HTTP client)

### Deployment
- **Cloud**: Azure Web Apps
- **CI/CD**: GitHub Actions (Automated deployment pipeline)
- **Containerization**: Docker & Docker Compose

---

## 🏗️ System Architecture

### High-Level Architecture Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER INTERFACE LAYER                       │
│  ┌──────────────────────┐  ┌──────────────────────────────────┐ │
│  │   Next.js Frontend   │  │   Flutter Mobile App            │ │
│  │  (React Components)  │  │   (Dart - diabp_mobile)         │ │
│  │  - Chatbot UI        │  │  - Health tracking              │ │
│  │  - Health Dashboard  │  │  - Diet plan viewer             │ │
│  │  - PDF Export        │  │  - Blood pressure/sugar logs    │ │
│  └──────────────────────┘  └──────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┬─┘
                                                                  │
                      HTTP/WebSocket Communication
                                                                  │
┌────────────────────────────────────────────────────────────────┴─┐
│                      API LAYER (FastAPI)                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  API Routes (api/chatbot.py, api/auth.py, etc.)        │   │
│  │  - /api/auth/* (Authentication)                         │   │
│  │  - /api/chat/* (Chat sessions & messages)              │   │
│  │  - /api/health/* (Health tracking)                      │   │
│  │  - /api/admin/* (Admin operations)                      │   │
│  │  - /ws/chat/* (WebSocket for real-time chat)           │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────��────────────────────��┬─┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
    ┌────▼────────┐  ┌────────▼──────┐  ┌─────────▼──────┐
    │ RAG Engine  │  │ Auth Service  │  │ Health Service │
    │ (Chatbot)   │  │ (Security)    │  │ (Data)         │
    └────┬────────┘  └────────┬──────┘  └─────────┬──────┘
         │                    │                    │
    ┌────▼────────────────────▼────────────────────▼───────────┐
    │           CORE SERVICES LAYER                            │
    │  ┌──────────────────────────────────────────────────┐    │
    │  │  RAG System (backend/ChatBot/)                  │    │
    │  │  ├─ gemini_llm.py: LLM integration             │    │
    │  │  ├─ retriever.py: Vector search (FAISS)        │    │
    │  │  ├─ knowledge_base.py: PDF processing          │    │
    │  │  ├─ ocr_parser.py: Medical document OCR        │    │
    │  │  └─ Sentiment & content filtering              │    │
    │  │                                                  │    │
    │  │  Authentication (bcrypt)                        │    │
    │  │  Session Management (with auto-cleanup)        │    │
    │  └──────────────────────────────────────────────────┘    │
    └────┬──────────────────────────────────────────────────┬───┘
         │                                                  │
    ┌────▼─────────────────────────────────────────────────▼──┐
    │           DATA PERSISTENCE LAYER                        │
    │  ┌──────────────────────────────────────────────────┐   │
    │  │  SQLAlchemy ORM (database/models.py)           │   │
    │  │  ├─ Users (id, email, password_hash)           │   │
    │  │  ├─ BMI Records (height, weight, category)     │   │
    │  │  ├─ Medical Records (documents, lab results)   │   │
    │  │  ├─ Chat Sessions (session_id, user_id)        │   │
    │  │  ├─ Chat Messages (content, embeddings)        │   │
    │  │  ├─ Diet Plans (duration, content, user_id)    │   │
    │  │  └─ Health Records (BP, glucose levels)        │   │
    │  │                                                  │   │
    │  │  SQLite Database                                │   │
    │  │  └─ instance/diet_consultant.db                │   │
    │  └──────────────────────────────────────────────────┘   │
    └──────────────────────────────────────────────────────────┘
         │
    ┌────▼──────────────────────────────────────────┐
    │  EXTERNAL SERVICES                           │
    │  ├─ Google Gemini API (LLM)                  │
    │  ├─ Sentence Transformers (Embeddings)      │
    │  ├─ FAISS (Vector similarity search)        │
    │  └─ Azure Web Apps (Deployment)             │
    └───────────────────────────────────────────────┘
>>>>>>> 4634baa02a1089327db956ddc1e17e06fd914004
```

### RAG (Retrieval-Augmented Generation) System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    RAG PIPELINE FLOW                        │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
   ┌────▼────┐            ┌──────▼──────┐
   │  Query  │            │ Knowledge   │
   │ (User   │            │   Base      │
   │ Message)│            �� (PDFs, docs)│
   └────┬────┘            └──────┬──────┘
        │                        │
   ┌────▼────────────────────────▼──────────┐
   │  1. EMBEDDING GENERATION               │
   │  - Sentence Transformers               │
   │  - Model: all-MiniLM-L6-v2            │
   │  - Output: 384-dim vector              │
   └────┬───────────────────────────────────┘
        │
   ┌────▼───────────────────────────────────┐
   │  2. VECTOR SIMILARITY SEARCH (FAISS)   │
   │  - Search across indexed documents     │
   │  - L2 distance metric                  │
   │  - Return top-5 most relevant chunks   │
   └────┬───────────────────────────────────┘
        │
   ┌────▼───────────────────────────────────┐
   │  3. CONTEXT AUGMENTATION               │
   │  - Retrieved chunks                    │
   │  - User health profile                 │
   │  - Medical history                     │
   │  - Combine into enriched prompt        │
   └────┬───────────────────────────────────┘
        │
   ┌────▼───────────────────────────────────┐
   │  4. LLM GENERATION (Google Gemini)    │
   │  - Model: gemini-2.5-flash-lite       │
   │  - Grounded in medical literature     │
   │  - Context-aware responses            │
   │  - Structured output formatting       │
   └────┬───────────────────────────────────┘
        │
   ┌────▼───────────────────────────────────┐
   │  5. RESPONSE PROCESSING                │
   │  - Format text (bullet points, etc.)   │
   │  - Add lifestyle recommendations       │
   │  - Add medical disclaimers             │
   │  - Filter inappropriate content       │
   │  - Return to user                      │
   └────────────────────────────────────────┘
```

---

## 📊 Database Schema

### Core Models (SQLAlchemy)

```python
# User Model
class User(Base):
    id: int (Primary Key)
    email: str (Unique)
    password_hash: str (bcrypt hashed)
    name: str
    age: int
    gender: str
    diabetes_type: str (Type 1, Type 2, Prediabetic, None)
    blood_pressure_systolic: int
    blood_pressure_diastolic: int
    created_at: DateTime
    updated_at: DateTime

# BMI Record
class BMI(Base):
    id: int (Primary Key)
    user_id: int (Foreign Key)
    height_cm: float
    weight_kg: float
    bmi_value: float (Calculated)
    category: str (Underweight, Normal, Overweight, Obese)
    recorded_at: DateTime

# Medical Record
class MedicalRecord(Base):
    id: int (Primary Key)
    user_id: int (Foreign Key)
    document_name: str
    extracted_text: str (OCR output)
    upload_date: DateTime
    blood_sugar: float (Optional)
    hba1c: float (Optional)

# Chat Session
class ChatSession(Base):
    id: str (UUID, Primary Key)
    user_id: int (Foreign Key)
    created_at: DateTime
    last_activity: DateTime
    expires_at: DateTime (Auto cleanup)

# Chat Message
class ChatMessage(Base):
    id: int (Primary Key)
    session_id: str (Foreign Key)
    sender: str (user, assistant)
    content: str
    timestamp: DateTime

# Diet Plan
class DietPlan(Base):
    id: int (Primary Key)
    user_id: int (Foreign Key)
    session_id: str (Foreign Key)
    duration_days: int (7, 10, 14, 21, 30)
    content: str (Full diet plan)
    generated_at: DateTime

# Health Tracking Record
class HealthRecord(Base):
    id: int (Primary Key)
    user_id: int (Foreign Key)
    blood_pressure_systolic: int
    blood_pressure_diastolic: int
    blood_sugar_fasting: float
    blood_sugar_random: float
    recorded_at: DateTime
```

---

## 🔐 Security Architecture

### Authentication Flow
```
┌────────────────┐
│  User Login    │
└────────┬───────┘
         │
    ┌────▼──────────────────────────┐
    │ Receive email & password      │
    │ Query User by email           │
    └────┬───────────────────────────┘
         │
    ┌────▼──────────────────────────┐
    │ bcrypt.checkpw()              │
    │ Compare with stored hash      │
    └────┬───────────────────────────┘
         │
    ┌────▼──────────────────────────┐
    │ Generate session token        │
    │ Store in database             │
    └────┬───────────────────────────┘
         │
    ┌────▼──────────────────────────┐
    │ Set expiration (24-48 hrs)    │
    │ Return token to client        │
    └────────────────────────────────┘

Periodic Cleanup:
- Every 6 hours, remove expired sessions
- Automatic on startup
```

### Security Features Implemented

| Feature | Implementation | Details |
|---------|-----------------|---------|
| **Password Hashing** | bcrypt (4.0.1) | Salt rounds: 10+, secure against rainbow tables |
| **Session Management** | Token-based | Auto-expiring sessions, periodic cleanup |
| **Input Validation** | Pydantic models | Type checking, required fields validation |
| **File Upload Security** | MIME type validation | Allowed: PDF, JPG, PNG (Max 25MB) |
| **CORS Protection** | FastAPI middleware | Configurable for development/production |
| **SQL Injection Prevention** | SQLAlchemy ORM | Parameterized queries |
| **Content Filtering** | Regex patterns | Block inappropriate/harmful terms |
| **Data Encryption** | Future: TLS/SSL | Password hashing with bcrypt |

---

## 📁 Detailed Project Structure

```
DietPlanner_mobile-app/
│
├── 📄 README.md                         # Project documentation
├── 📄 package.json                      # Frontend dependencies
├── 📄 package-lock.json                 # Dependency lock file
├── 📄 postcss.config.js                 # PostCSS configuration
├── 📄 tailwind.config.js                # Tailwind CSS configuration
├── 📄 .gitignore                        # Git ignore rules
│
├── 📁 backend/                          # Python FastAPI Backend (56.6%)
│   ├── 📄 app.py                        # Main FastAPI application
│   ├── 📄 models.py                     # SQLAlchemy ORM models
│   ├── 📄 requirements.txt               # Python dependencies
│   │
│   ├── 📁 api/                          # API Endpoints
│   │   ├── 📄 chatbot.py                # Chatbot routes & WebSocket
│   │   ├── 📄 auth.py                   # Authentication endpoints
│   │   ├── 📄 health.py                 # Health tracking endpoints
│   │   └── 📄 admin.py                  # Admin dashboard endpoints
│   │
│   ├── 📁 ChatBot/                      # RAG System Core
│   │   ├── 📄 gemini_llm.py             # Google Gemini integration
│   │   │   - LLM API calls
│   │   │   - Error handling
│   │   │   - Fallback responses
│   │   │
│   │   ├── 📄 retriever.py              # Vector search engine
│   │   │   - FAISS index loading
│   │   │   - Semantic similarity search
│   │   │   - Top-k retrieval
│   │   │
│   │   ├── 📄 knowledge_base.py         # Document processing
│   │   │   - PDF chunk extraction
│   │   │   - Batch ingestion
│   │   │   - Embedding generation
│   │   │
│   │   ├── 📄 ocr_parser.py             # Medical document OCR
│   │   │   - Tesseract OCR processing
│   │   │   - Medical data extraction
│   │   │   - Text normalization
│   │   │
│   │   ├── 📁 data/                     # Knowledge base
│   │   │   ├── 📄 medical_guidelines.pdf
│   │   │   ├── 📄 nutrition_data.pdf
│   │   │   └── 📁 user_uploads/        # User medical documents
│   │   │
│   │   └── 📁 models/                   # Pre-trained models
│   │       └── 📄 all-MiniLM-L6-v2/    # Sentence transformer model
│   │
│   ├── 📁 faiss/                        # FAISS Vector Indices
│   │   ├── 📄 medical_guidelines.index  # Vector index
│   │   └── 📄 medical_guidelines_chunks.txt
│   │
│   ├── 📁 instance/                     # Database
│   │   └── 📄 diet_consultant.db        # SQLite database
│   │
│   ├── 📁 exports/                      # Data export folder
│   │   ├── 📄 users.csv
│   │   └── 📄 diet_plans_export.csv
│   │
│   └── 📁 tests/                        # Test suite
│       ├── 📄 test_auth.py              # Authentication tests
│       ├── 📄 test_chatbot.py           # Chatbot functionality tests
│       └── 📄 test_health.py            # Health tracking tests
│
├── 📁 frontend/                         # Next.js Frontend (43%)
│   ├── 📁 pages/                        # Next.js pages
│   │   ├── 📄 index.js                  # Home page
│   │   ├── 📄 login.js                  # Login page
│   │   ├── 📄 signup.js                 # Registration page
│   │   ├── 📄 dashboard.js              # User dashboard
│   │   ├── 📄 health-profile.js         # Health profile editor
│   │   ├── 📄 chatbot.js                # Chat interface
│   │   ├── 📄 diet-plans.js             # Diet plan history
│   │   └── 📄 admin.js                  # Admin dashboard
│   │
│   ├── 📁 components/                   # Reusable React components
│   │   ├── 📄 Chatbot.js                # Floating chat widget
│   │   ├── 📄 Header.js                 # Navigation header
│   │   ├── 📄 Layout.js                 # Main layout wrapper
│   │   ├── 📄 BMICalculator.js          # BMI calculation form
│   │   ├── 📄 HealthTracker.js          # Health tracking form
│   │   ├── 📄 DietPlanViewer.js         # Diet plan display
│   │   └── 📄 AdminDashboard.js         # Admin panel
│   │
│   ├── 📁 context/                      # React Context API
│   │   ├── 📄 AuthContext.js            # Authentication state
│   │   ├── 📄 UserContext.js            # User data state
│   │   └── 📄 ChatContext.js            # Chat session state
│   │
│   ├── 📁 utils/                        # Utility functions
│   │   ├── 📄 api.js                    # API client wrapper
│   │   ├── 📄 validators.js             # Input validation
│   │   └── 📄 formatters.js             # Data formatting
│   │
│   ├── 📁 styles/                       # CSS & styling
│   │   ├── 📄 globals.css               # Global styles
│   │   └── 📄 theme.css                 # Theme variables
│   │
│   └── 📁 public/                       # Static assets
│       ├── 📁 images/
│       └── 📁 icons/
│
├── 📁 diabp_mobile/                     # Flutter Mobile App (Dart)
│   ├── 📄 README.md                     # Flutter project docs
│   ├── 📄 pubspec.yaml                  # Flutter dependencies
│   ├── 📁 lib/                          # Dart source code
│   │   ├── 📄 main.dart                 # App entry point
│   │   ├── 📁 screens/                  # UI screens
│   │   ├── 📁 models/                   # Data models
│   │   └── 📁 services/                 # API services
│   └── 📁 test/                         # Flutter tests
│
├── 📁 docs/                             # Documentation
│   ├── 📄 API_DOCUMENTATION.md          # Detailed API docs
│   ├── 📄 SETUP_GUIDE.md                # Setup instructions
│   ├── 📄 ARCHITECTURE.md               # System architecture
│   └── 📄 TROUBLESHOOTING.md            # Common issues
│
├── 📁 .github/                          # GitHub configuration
│   └── 📁 workflows/
│       └── 📄 main_daibpdietplanner.yml # Azure CI/CD pipeline
│
└── 📄 docker-compose.yml                # Docker configuration
```

---

## 🔗 API Endpoints Specification

### Authentication Endpoints
```
POST /api/auth/signup
├─ Request: { email, password, name, age, gender }
├─ Response: { user_id, token, expires_in }
└─ Status: 200 (Success) | 409 (Email exists) | 400 (Invalid input)

POST /api/auth/login
├─ Request: { email, password }
├─ Response: { user_id, token, expires_in }
└─ Status: 200 (Success) | 401 (Invalid credentials) | 404 (User not found)

GET /api/auth/logout
├─ Header: Authorization: Bearer {token}
├─ Response: { message: "Logged out successfully" }
└─ Status: 200 (Success)

POST /api/auth/refresh-token
├─ Request: { refresh_token }
├─ Response: { new_token, expires_in }
└─ Status: 200 (Success) | 401 (Invalid token)
```

### Chat/Chatbot Endpoints
```
POST /api/chat/session
├─ Header: Authorization: Bearer {token}
├─ Response: { session_id, created_at }
└─ Status: 201 (Created)

POST /api/chat/{session_id}/message
├─ Header: Authorization: Bearer {token}
├─ Request: { content, message_type }
├─ Response: { message_id, response, timestamp }
└─ Status: 200 (Success) | 404 (Session not found)

WebSocket /ws/chat/{session_id}
├─ Connect: ws://backend:8000/ws/chat/{session_id}
├─ Send: { type: "message", content: "..." }
├─ Receive: { type: "response", content: "..." }
└─ Auto-reconnect on disconnect

POST /api/chat/{session_id}/generate-diet-plan
├─ Header: Authorization: Bearer {token}
├─ Request: { duration: "7_days|10_days|14_days|21_days|30_days" }
├─ Response: { 
│   plan_id, 
│   duration_days, 
│   content, 
│   sections: { breakfast, lunch, dinner, snacks },
│   nutritional_info: { calories, protein, carbs, fat }
│  }
└─ Status: 200 (Success) | 400 (Invalid duration)

GET /api/chat/{session_id}/medical-data
├─ Header: Authorization: Bearer {token}
├─ Response: { extracted_data, documents, blood_sugar, blood_pressure }
└─ Status: 200 (Success)

GET /api/chat/{session_id}/history
├─ Header: Authorization: Bearer {token}
├─ Query: ?limit=50&offset=0
├─ Response: [{ message_id, content, sender, timestamp }]
└─ Status: 200 (Success)
```

### Health Tracking Endpoints
```
POST /api/health/bmi
├─ Header: Authorization: Bearer {token}
├─ Request: { height_cm, weight_kg }
├─ Response: { bmi, category, recommendations }
└─ Status: 200 (Success)

POST /api/health/records
├─ Header: Authorization: Bearer {token}
├─ Request: { 
│   blood_pressure_systolic, 
│   blood_pressure_diastolic, 
│   blood_sugar_fasting,
│   recorded_at
│  }
├─ Response: { record_id, created_at }
└─ Status: 201 (Created)

GET /api/health/records
├─ Header: Authorization: Bearer {token}
├─ Query: ?start_date=2024-01-01&end_date=2024-12-31&limit=100
├─ Response: [{ record_id, bp, glucose, recorded_at }]
└─ Status: 200 (Success)

PUT /api/health/profile
├─ Header: Authorization: Bearer {token}
├─ Request: { diabetes_type, age, gender, medical_history }
├─ Response: { profile_id, updated_at }
└─ Status: 200 (Success)

GET /api/health/profile
├─ Header: Authorization: Bearer {token}
├─ Response: { user_id, profile_data, medical_history }
└─ Status: 200 (Success)

POST /api/health/medical-documents
├─ Header: Authorization: Bearer {token}
├─ Content-Type: multipart/form-data
├─ Body: file (PDF/JPG/PNG, max 25MB)
├─ Response: { 
│   document_id, 
│   extracted_text, 
│   medical_data: { blood_sugar, hba1c, etc. },
│   upload_date
│  }
└─ Status: 200 (Success) | 413 (File too large)
```

### Admin Endpoints
```
GET /api/admin/users
├─ Header: Authorization: Bearer {admin_token}
├─ Query: ?page=1&per_page=50&search=email
├─ Response: { 
│   users: [{ user_id, email, name, created_at }],
│   total,
│   page,
│   per_page
│  }
└─ Status: 200 (Success) | 403 (Forbidden)

GET /api/admin/users/{user_id}/health
├─ Header: Authorization: Bearer {admin_token}
├─ Response: { health_records, diet_plans, medical_documents }
└─ Status: 200 (Success)

GET /api/admin/analytics
├─ Header: Authorization: Bearer {admin_token}
├─ Response: { 
│   total_users, 
│   active_sessions, 
│   diet_plans_generated,
│   avg_health_metrics
│  }
└─ Status: 200 (Success)

POST /api/admin/export
├─ Header: Authorization: Bearer {admin_token}
├─ Request: { export_type: "users|diet_plans|health" }
├─ Response: { file_url, expires_in }
└─ Status: 200 (Success)
```

---

## 📋 Dependencies Deep Dive

### Backend Dependencies (Python)

| Package | Version | Purpose | Why Used |
|---------|---------|---------|-----------|
| **fastapi** | Latest | Web framework | Fast, async, auto-docs |
| **uvicorn** | Latest | ASGI server | Efficient async support |
| **SQLAlchemy** | 2.0.4 | ORM | Database abstraction |
| **bcrypt** | 4.0.1 | Password hashing | Security standard |
| **sentence-transformers** | Latest | Text embeddings | Medical text understanding |
| **faiss-cpu** | Latest | Vector search | Fast similarity search |
| **google-generativeai** | Latest | LLM API | State-of-the-art language model |
| **pymupdf** | Latest | PDF processing | Efficient text extraction |
| **pytesseract** | Latest | OCR | Medical document scanning |
| **pdfplumber** | Latest | PDF parsing | Table extraction |
| **llama-index** | Latest | RAG framework | Document indexing |
| **pytest** | Latest | Testing | Unit/integration tests |
| **websockets** | Latest | Real-time chat | WebSocket support |

### Frontend Dependencies (JavaScript/Node)

| Package | Version | Purpose | Why Used |
|---------|---------|---------|----------|
| **next** | 13.4.19 | React framework | SSR, routing, optimization |
| **react** | 18.2.0 | UI library | Component-based UI |
| **axios** | 1.9.0 | HTTP client | API communication |
| **jspdf** | 2.5.1 | PDF generation | Client-side PDF creation |
| **tailwindcss** | 3.3.3 | CSS framework | Utility-first styling |
| **react-datepicker** | 4.16.0 | Date input | Health tracking dates |

---

## 🚀 Advanced Setup Guide

### Prerequisites
- **Node.js**: v16+ (Recommended: v18 LTS)
- **Python**: v3.8+ (Recommended: v3.10+)
- **Tesseract OCR**: System dependency for image processing
- **FAISS**: Pre-built indices in `backend/faiss/`
- **Git**: Version control

### Tesseract OCR Installation

**Linux (Ubuntu/Debian)**
```bash
<<<<<<< HEAD
git clone <repository-url>
cd DietPlanner_mobile
=======
sudo apt-get update
sudo apt-get install tesseract-ocr
sudo apt-get install libtesseract-dev
>>>>>>> 4634baa02a1089327db956ddc1e17e06fd914004
```

**macOS**
```bash
brew install tesseract
```

**Windows**
- Download installer: https://github.com/UB-Mannheim/tesseract/wiki
- Add to PATH after installation

### Backend Setup (Detailed)

```bash
# 1. Navigate to backend
cd backend

# 2. Create virtual environment (Optional but recommended)
python -m venv venv
source venv/bin/activate  # Linux/macOS
# OR
venv\Scripts\activate     # Windows

# 3. Install dependencies
pip install -r requirements.txt
# OR using uv (faster)
uv sync

# 4. Create .env file
cat > .env << EOF
GEMINI_API_KEY=your_gemini_api_key_here
MAX_UPLOAD_SIZE_MB=25
ALLOWED_MIME_TYPES=application/pdf,image/jpeg,image/jpg,image/png
DATABASE_URL=sqlite:///instance/diet_consultant.db
CORS_ORIGINS=http://localhost:3000,http://localhost:3001
EOF

# 5. Initialize database (Auto-created but verify)
python
>>> from models import Base, engine
>>> Base.metadata.create_all(engine)
>>> exit()

# 6. Ingest knowledge base (First time only)
uv run batch_ingest.py --pdf_dir data/medical_pdfs --output_dir faiss

# 7. Run server
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Setup (Detailed)

```bash
<<<<<<< HEAD
cd diabp_mobile
flutter pub get
```

#### Run the Application
```bash
# Run on Chrome
flutter run -d chrome

# Run on an Android emulator or connected device
flutter run
```

### 4. Access the Application
- **Frontend**: The app will launch in your browser (if using Chrome) or on your device/emulator.
=======
# 1. Navigate to frontend (from repo root)
cd frontend  # or root if index.js is in root

# 2. Install dependencies
npm install

# 3. Create .env.local file
cat > .env.local << EOF
NEXT_PUBLIC_BACKEND_BASE_URL=http://127.0.0.1:8000
NEXT_PUBLIC_API_TIMEOUT=30000
NEXT_PUBLIC_ENVIRONMENT=development
EOF

# 4. Run development server
npm run dev
# Accessible at http://localhost:3000

# 5. Build for production
npm run build
npm start

# 6. Code quality check
npm run lint
```

### Access Running Services
- **Frontend**: http://localhost:3000
>>>>>>> 4634baa02a1089327db956ddc1e17e06fd914004
- **Backend API**: http://127.0.0.1:8000
- **API Docs (Swagger)**: http://127.0.0.1:8000/docs
- **API Redoc**: http://127.0.0.1:8000/redoc

---

## 🔧 Configuration

### Environment Variables

#### Backend (.env)
```env
# API Keys
GEMINI_API_KEY=your_gemini_api_key_here

# File Upload
MAX_UPLOAD_SIZE_MB=25
ALLOWED_MIME_TYPES=application/pdf,image/jpeg,image/jpg,image/png

# Database
DATABASE_URL=sqlite:///instance/diet_consultant.db

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:3001

# Session Management
SESSION_EXPIRY_HOURS=24
CLEANUP_INTERVAL_HOURS=6

# Logging
LOG_LEVEL=INFO
```

<<<<<<< HEAD
#### Frontend (diabp_mobile/lib/core/constants.dart)
Depending on how your app is structured, make sure the `AppConstants` or similar file points to the correct backend IP. E.g., `http://127.0.0.1:8000` or `http://<your-network-ip>:8000`.
=======
#### Frontend (.env.local)
```env
NEXT_PUBLIC_BACKEND_BASE_URL=http://127.0.0.1:8000
NEXT_PUBLIC_API_TIMEOUT=30000
NEXT_PUBLIC_ENVIRONMENT=development
NEXT_PUBLIC_MAX_FILE_SIZE=26214400
```
>>>>>>> 4634baa02a1089327db956ddc1e17e06fd914004

### Database
- **SQLite**: Default database (backend/instance/diet_consultant.db)
- **Auto-creation**: Database and tables created automatically on startup
- **Location**: Relative to backend directory

---

## 🧪 Testing Strategy

### Backend Testing
```bash
# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=backend --cov-report=html

# Run specific test
pytest tests/test_chatbot.py::test_generate_diet_plan -v

# Run async tests
pytest tests/ -v -k "async"

# Test configuration in pytest.ini
[pytest]
asyncio_mode = auto
testpaths = tests
python_files = test_*.py
```

### Frontend Testing
```bash
<<<<<<< HEAD
cd diabp_mobile
flutter test
=======
# Unit tests
npm test

# Test coverage
npm test -- --coverage

# E2E tests (if set up)
npm run test:e2e
>>>>>>> 4634baa02a1089327db956ddc1e17e06fd914004
```

### Manual Testing Scenarios

**Authentication Flow**
1. Sign up with new email
2. Login with credentials
3. Verify session persistence
4. Test logout
5. Verify token expiration

**Health Profile**
1. Enter height/weight
2. Verify BMI calculation
3. Upload medical document
4. Verify OCR extraction
5. Check health record storage

**Diet Plan Generation**
1. Start chat session
2. Request 7-day diet plan
3. Verify response includes meals
4. Download as PDF
5. Check formatting

---

## 🐳 Docker Deployment

<<<<<<< HEAD
## 🚀 Deployment

### Production Setup
1. **Environment**: Set production environment variables
2. **Database**: Configure production database
3. **Frontend Build**: Use `flutter build web` or `flutter build apk`
4. **Process Management**: Use PM2 or similar for the backend
5. **Reverse Proxy**: Configure Nginx

### Docker Deployment
=======
### Docker Compose Setup
>>>>>>> 4634baa02a1089327db956ddc1e17e06fd914004
```bash
# Build and start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild after code changes
docker-compose up -d --build
```

### Docker Compose Configuration
```yaml
version: '3.9'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - DATABASE_URL=sqlite:///instance/diet_consultant.db
    volumes:
      - ./backend:/app
    command: uvicorn app:app --host 0.0.0.0 --reload

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_BACKEND_BASE_URL=http://backend:8000
    volumes:
      - ./frontend:/app

  # Optional: Database backup service
  db-backup:
    image: busybox
    volumes:
      - ./backend/instance:/app/instance
    command: tar czf /app/backup.tar.gz /app/instance
```

---

## 📈 Performance Optimization

### Backend Optimization
1. **Database Indexing**
   - Create indices on frequently queried fields
   - User emails, session IDs, created_at dates

2. **Caching Strategy**
   - Cache LLM responses for common queries
   - Cache medical document embeddings
   - Redis integration (future)

3. **Async Processing**
   - PDF processing in background tasks
   - Batch embedding generation
   - Session cleanup runs async

4. **Load Management**
   - Connection pooling
   - Rate limiting (future)
   - Request timeout handling

### Frontend Optimization
1. **Code Splitting**: Next.js automatic page splitting
2. **Image Optimization**: Next.js Image component
3. **Lazy Loading**: React Suspense for components
4. **State Management**: Context API over Redux for simplicity
5. **Bundle Size**: ESLint rules to prevent bloat

### RAG System Optimization
1. **Vector Index**: FAISS with GPU support (GPU optional)
2. **Embedding Batching**: Process multiple texts together
3. **Top-K Retrieval**: Limit to 5 most relevant chunks
4. **Prompt Optimization**: Concise, well-structured prompts

---

## 🔄 CI/CD Pipeline (GitHub Actions)

### Current Deployment Workflow
```yaml
# .github/workflows/main_daibpdietplanner.yml
name: Build and Deploy to Azure

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Python 3.10
        uses: actions/setup-python@v5
        with:
          python-version: 3.10
      - name: Install dependencies
        run: |
          cd backend
          pip install -r requirements.txt
      - name: Upload artifact
        uses: actions/upload-artifact@v4

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
      - name: Login to Azure
        uses: azure/login@v2
      - name: Deploy
        uses: azure/webapps-deploy@v3
```

---

## 🛡️ Error Handling & Logging

### Backend Error Handling
```python
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": exc.detail, "timestamp": datetime.now()},
    )

# Custom error classes
class DietPlanGenerationError(Exception):
    pass

class OCRExtractionError(Exception):
    pass

class VectorSearchError(Exception):
    pass
```

### Logging Setup
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('backend.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)
```

---

## 📞 Support & Troubleshooting

### Common Issues

**Issue: "GEMINI_API_KEY not found"**
- Solution: Add key to `.env` file in backend directory
- Verify: `echo $GEMINI_API_KEY` in terminal

**Issue: "Tesseract not found"**
- Solution: Install system-wide (see prerequisites)
- Verify: `tesseract --version`

**Issue: "Port 8000 already in use"**
- Solution: Kill process: `lsof -i :8000` then `kill -9 <PID>`
- Alternative: Change port in uvicorn command

**Issue: "Database locked"**
- Solution: Restart backend server
- Check: Ensure only one process uses database

**Issue: "CORS errors in browser"**
- Solution: Verify `CORS_ORIGINS` in `.env`
- Check: Frontend URL matches backend config

### Getting Help
- Open GitHub issue with detailed description
- Include error logs and system info
- Provide reproducible steps
- Check existing issues first

---

## 🤝 Contributing Guidelines

### Development Workflow
1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes with tests
3. Commit with meaningful messages
4. Submit pull request with description
5. Pass CI/CD checks
6. Code review approval
7. Merge to main

### Code Style
- **Python**: PEP 8 compliance (use Black formatter)
- **JavaScript**: ESLint configuration
- **Commits**: Conventional commits format

---

## 📚 Additional Resources

- **API Documentation**: http://localhost:8000/docs (Interactive Swagger UI)
- **Google Gemini Docs**: https://ai.google.dev
- **FAISS Documentation**: https://github.com/facebookresearch/faiss
- **FastAPI Guide**: https://fastapi.tiangolo.com
- **Next.js Docs**: https://nextjs.org/docs

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

<<<<<<< HEAD
- **Google Gemini** for AI capabilities
- **FastAPI** for the backend framework
- **Flutter** for the cross-platform UI framework
- **Medical research community** for diet and health guidelines

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check the documentation in `/docs/`
- Review the API documentation at `/docs`
=======
- **Google Gemini Team** for powerful AI capabilities
- **FastAPI Community** for excellent documentation
- **Next.js Team** for frontend framework
- **Tailwind CSS** for beautiful styling utilities
- **Medical Research Community** for health guidelines
- **Open Source Contributors** for all libraries used
>>>>>>> 4634baa02a1089327db956ddc1e17e06fd914004

---

**Built with ❤️ for better health outcomes**

*Last Updated: 2026-04-18 19:25:56*
*Version: 0.1.0 (Beta)*
