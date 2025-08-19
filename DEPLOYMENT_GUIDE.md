# 🚀 SERENYX DEPLOYMENT GUIDE

## 📋 Table of Contents
1. [Backend Deployment on Render](#backend-deployment-on-render)
2. [Voice Guidance Setup](#voice-guidance-setup)
3. [Environment Configuration](#environment-configuration)
4. [Flutter App Configuration](#flutter-app-configuration)
5. [Testing & Verification](#testing--verification)

---

## 🎯 Backend Deployment on Render

### Step 1: Prepare Your Repository
1. Ensure your backend code is in the `backend/` directory
2. Verify all dependencies are in `package.json`
3. Check that `render.yaml` is properly configured

### Step 2: Create Render Account
1. Go to [render.com](https://render.com)
2. Sign up with GitHub/GitLab
3. Connect your repository

### Step 3: Deploy Backend Service
1. **Create New Web Service**
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select the repository containing your backend

2. **Configure Service Settings**
   ```
   Name: serenyx-api
   Environment: Node
   Build Command: npm install && npm run build
   Start Command: npm start
   Plan: Starter (Free tier)
   ```

3. **Set Environment Variables**
   - Click "Environment" tab
   - Add the following variables:

   ```bash
   NODE_ENV=production
   PORT=3000
   LOG_LEVEL=info
   
   # Firebase Configuration
   FIREBASE_PROJECT_ID=your-firebase-project-id
   FIREBASE_CLIENT_EMAIL=your-firebase-client-email
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour Private Key Here\n-----END PRIVATE KEY-----\n"
   FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
   
   # ElevenLabs Configuration
   ELEVENLABS_API_KEY=your-elevenlabs-api-key
   
   # Security
   JWT_SECRET=your-super-secret-jwt-key-here
   ENCRYPTION_KEY=your-32-character-encryption-key
   
   # CORS
   ALLOWED_ORIGINS=https://serenyx.com,https://www.serenyx.com,https://app.serenyx.com,https://serenyx-app.vercel.app,https://serenyx-app.netlify.app,capacitor://localhost,ionic://localhost
   ```

4. **Deploy**
   - Click "Create Web Service"
   - Wait for build and deployment to complete
   - Your API will be available at: `https://serenyx-api.onrender.com`

### Step 4: Verify Deployment
1. Test health endpoint: `https://serenyx-api.onrender.com/api/health`
2. Check logs in Render dashboard
3. Verify all environment variables are set correctly

---

## 🎤 Voice Guidance Setup

### Step 1: ElevenLabs Account Setup
1. Go to [elevenlabs.io](https://elevenlabs.io)
2. Create a free account
3. Navigate to "Profile" → "API Key"
4. Copy your API key

### Step 2: Configure Voice Settings
1. **Add API Key to Render**
   - Go to your Render service dashboard
   - Environment → Add Variable
   - Key: `ELEVENLABS_API_KEY`
   - Value: Your ElevenLabs API key

2. **Test Voice Generation**
   ```bash
   curl -X POST https://serenyx-api.onrender.com/api/voice/text-to-speech \
     -H "Content-Type: application/json" \
     -d '{
       "text": "Hello! Welcome to Serenyx.",
       "voice": "pNInz6obpgDQGcFmaJgB",
       "speed": 1.0,
       "pitch": 0
     }'
   ```

### Step 3: Voice Features Available
- **Text-to-Speech**: Convert any text to natural speech
- **Onboarding Guidance**: Step-by-step voice guidance
- **Achievement Celebrations**: Voice celebrations for achievements
- **Health Reminders**: Voice reminders for pet care tasks
- **Feedback Messages**: Success, error, warning, info messages
- **Voice Commands**: Process voice commands (future feature)

---

## ⚙️ Environment Configuration

### Backend Environment Variables
```bash
# Required Variables
NODE_ENV=production
PORT=3000
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account-email
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
ELEVENLABS_API_KEY=your-elevenlabs-key
JWT_SECRET=your-jwt-secret
ENCRYPTION_KEY=your-encryption-key

# Optional Variables
LOG_LEVEL=info
ALLOWED_ORIGINS=https://serenyx.com,https://www.serenyx.com
RATE_LIMIT_MAX_REQUESTS=100
MAX_FILE_SIZE=10485760
```

### Flutter Environment Configuration
```dart
// lib/core/config/api_config.dart
static const String prodBaseUrl = 'https://serenyx-api.onrender.com/api';
```

---

## 📱 Flutter App Configuration

### Step 1: Update API Configuration
1. Open `lib/core/config/api_config.dart`
2. Verify production URL is set to Render deployment
3. Update any other environment-specific settings

### Step 2: Add Voice Guidance Dependencies
```yaml
# pubspec.yaml
dependencies:
  audioplayers: ^5.2.1
  flutter_tts: ^3.8.5
  speech_to_text: ^6.6.0
```

### Step 3: Initialize Voice Service
```dart
// In your main.dart or app initialization
final voiceService = VoiceGuidanceService();
await voiceService.initialize();
```

### Step 4: Test Voice Features
```dart
// Test voice guidance
await voiceService.speak("Welcome to Serenyx!");

// Test onboarding voice
await voiceService.speakOnboarding("welcome", petName: "Buddy");

// Test achievement voice
await voiceService.speakAchievement("First Pet", "Buddy", "common");
```

---

## 🧪 Testing & Verification

### Backend API Tests
```bash
# Health Check
curl https://serenyx-api.onrender.com/api/health

# Voice Generation Test
curl -X POST https://serenyx-api.onrender.com/api/voice/text-to-speech \
  -H "Content-Type: application/json" \
  -d '{"text": "Test message", "voice": "pNInz6obpgDQGcFmaJgB"}'

# Get Available Voices
curl https://serenyx-api.onrender.com/api/voice/voices

# Authentication Test
curl -X GET https://serenyx-api.onrender.com/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Flutter App Tests
1. **Build for Production**
   ```bash
   flutter build apk --dart-define=ENVIRONMENT=prod
   flutter build ios --dart-define=ENVIRONMENT=prod
   ```

2. **Test Voice Features**
   - Onboarding voice guidance
   - Achievement celebrations
   - Health reminders
   - Feedback messages

3. **Test API Integration**
   - Pet management
   - User authentication
   - Gamification features
   - Social features

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Backend Deployment Fails
- **Issue**: Build fails on Render
- **Solution**: Check `package.json` and `render.yaml` configuration
- **Check**: Node.js version compatibility

#### 2. Voice Generation Not Working
- **Issue**: ElevenLabs API errors
- **Solution**: Verify API key is correct and has sufficient credits
- **Check**: API key permissions and rate limits

#### 3. CORS Errors
- **Issue**: Flutter app can't connect to backend
- **Solution**: Update `ALLOWED_ORIGINS` in Render environment variables
- **Check**: Include your Flutter app's domain

#### 4. Firebase Connection Issues
- **Issue**: Backend can't connect to Firebase
- **Solution**: Verify Firebase credentials and project settings
- **Check**: Service account permissions

### Debug Commands
```bash
# Check Render logs
# Go to Render dashboard → Your service → Logs

# Test API endpoints locally
curl http://localhost:3000/api/health

# Check environment variables
echo $NODE_ENV
echo $FIREBASE_PROJECT_ID
```

---

## 📊 Monitoring & Analytics

### Render Dashboard
- Monitor service health
- View request logs
- Check performance metrics
- Set up alerts

### Firebase Console
- Monitor database usage
- Check authentication logs
- View storage usage
- Set up monitoring alerts

### ElevenLabs Dashboard
- Monitor API usage
- Check voice generation credits
- View usage analytics

---

## 🚀 Production Checklist

### Backend
- [ ] Deployed to Render
- [ ] Environment variables configured
- [ ] Health endpoint responding
- [ ] Voice generation working
- [ ] Firebase connection established
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] Security headers set

### Flutter App
- [ ] API configuration updated
- [ ] Voice service integrated
- [ ] Production build tested
- [ ] All features working
- [ ] Error handling implemented
- [ ] Performance optimized

### Voice Features
- [ ] ElevenLabs API key configured
- [ ] Voice generation tested
- [ ] Onboarding voice working
- [ ] Achievement celebrations working
- [ ] Health reminders working
- [ ] Feedback messages working

---

## 🎉 Success!

Your Serenyx Pet Wellness App is now deployed with:
- ✅ Production backend on Render
- ✅ Voice guidance system
- ✅ Gamification features
- ✅ Social features
- ✅ Real-time data synchronization
- ✅ Professional-grade security

**Ready for App Store submission!** 🚀