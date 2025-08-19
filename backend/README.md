# Serenyx Backend API

A production-ready TypeScript backend API for the Serenyx Pet Wellness App, featuring Firebase authentication, Firestore database, ElevenLabs integration, and comprehensive security features.

## Features

- 🔐 **Firebase Authentication** - Secure user authentication and authorization
- 🗄️ **Firestore Database** - Real-time data storage and synchronization
- 🎵 **ElevenLabs Integration** - AI-powered soundscape generation
- 🗳️ **Voting System** - Best Pet contest with real-time voting
- 📊 **Audit Logging** - Comprehensive activity tracking
- 🛡️ **Security** - Rate limiting, CORS, input validation
- 📝 **Zod Validation** - Type-safe request validation
- 🚀 **Production Ready** - Error handling, logging, monitoring

## Quick Start

### Prerequisites

- Node.js 18+ 
- Firebase project with Firestore and Storage enabled
- ElevenLabs API key (optional, for soundscape generation)

### Installation

1. **Clone and install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase and ElevenLabs credentials
   ```

3. **Build the project:**
   ```bash
   npm run build
   ```

4. **Start the server:**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

## API Endpoints

### Authentication
- `GET /api/auth/me` - Get current user info
- `POST /api/auth/token` - Create custom token

### Pets
- `GET /api/pets` - Get user's pets
- `GET /api/pets/:petId` - Get specific pet
- `POST /api/pets` - Create new pet
- `PUT /api/pets/:petId` - Update pet
- `DELETE /api/pets/:petId` - Delete pet

### Voting (Best Pet Contest)
- `GET /api/voting` - Get all contest entries
- `POST /api/voting/submit` - Submit pet for contest
- `POST /api/voting/vote` - Vote for a pet
- `GET /api/voting/history` - Get voting history
- `GET /api/voting/stats` - Get contest statistics

### Soundscapes
- `GET /api/soundscape` - Get user's soundscapes
- `GET /api/soundscape/public` - Get public soundscapes
- `POST /api/soundscape` - Create soundscape
- `POST /api/soundscape/generate` - Generate AI soundscape
- `GET /api/soundscape/voices` - Get available voices
- `PUT /api/soundscape/:id` - Update soundscape
- `DELETE /api/soundscape/:id` - Delete soundscape

### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `GET /api/users/stats` - Get user statistics
- `GET /api/users/pets` - Get user's pets
- `GET /api/users/soundscapes` - Get user's soundscapes
- `GET /api/users/votes` - Get voting history

### Health
- `GET /api/health` - Basic health check
- `GET /api/health/detailed` - Detailed health check
- `GET /api/health/ready` - Kubernetes readiness probe
- `GET /api/health/live` - Kubernetes liveness probe

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `PORT` | Server port | No (default: 3000) |
| `NODE_ENV` | Environment | No (default: development) |
| `FIREBASE_PROJECT_ID` | Firebase project ID | Yes |
| `FIREBASE_CLIENT_EMAIL` | Firebase service account email | Yes |
| `FIREBASE_PRIVATE_KEY` | Firebase private key | Yes |
| `FIREBASE_STORAGE_BUCKET` | Firebase storage bucket | Yes |
| `ELEVENLABS_API_KEY` | ElevenLabs API key | No |
| `ALLOWED_ORIGINS` | CORS allowed origins | No |

## Security Features

- **Rate Limiting** - 100 requests per 15 minutes per IP
- **Input Validation** - Zod schema validation for all requests
- **CORS Protection** - Configurable cross-origin resource sharing
- **Helmet Security** - Security headers and CSP
- **Audit Logging** - Comprehensive activity tracking
- **Error Handling** - Structured error responses

## Development

### Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run test         # Run tests
npm run lint         # Lint code
npm run format       # Format code
```

### Project Structure

```
src/
├── controllers/     # Route controllers
├── middleware/      # Express middleware
├── models/          # Data models and validation
├── routes/          # API routes
├── services/        # Business logic
├── utils/           # Utilities and helpers
└── index.ts         # Main entry point
```

## Deployment

### Docker

```bash
# Build image
docker build -t serenyx-backend .

# Run container
docker run -p 3000:3000 --env-file .env serenyx-backend
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: serenyx-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: serenyx-backend
  template:
    metadata:
      labels:
        app: serenyx-backend
    spec:
      containers:
      - name: serenyx-backend
        image: serenyx-backend:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: FIREBASE_PROJECT_ID
          valueFrom:
            secretKeyRef:
              name: firebase-secret
              key: project-id
```

## Monitoring

The API includes comprehensive logging and monitoring:

- **Winston Logging** - Structured logging with multiple transports
- **Audit Logging** - User activity tracking
- **Security Logging** - Authentication and authorization events
- **Health Checks** - Kubernetes-ready health endpoints
- **Error Tracking** - Detailed error logging with stack traces

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details