import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import slowDown from 'express-slow-down';
import dotenv from 'dotenv';

// Import middleware
import { errorHandler } from './middleware/errorHandler';
import { auditLogger } from './middleware/auditLogger';
import { authMiddleware } from './middleware/auth';

// Import routes
import authRoutes from './routes/auth';
import petRoutes from './routes/pets';
import soundscapeRoutes from './routes/soundscape';
import votingRoutes from './routes/voting';
import userRoutes from './routes/users';
import healthRoutes from './routes/health';
import gamificationRoutes from './routes/gamification';
import voiceRoutes from './routes/voice';

// Import services
import { initializeFirebase } from './services/firebase';
import { logger } from './utils/logger';

// Load environment variables
dotenv.config();

const app = express();

// Environment configuration
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';
const isProduction = NODE_ENV === 'production';

// CORS configuration for production
const corsOptions = {
  origin: isProduction 
    ? [
        'https://serenyx.com',
        'https://www.serenyx.com',
        'https://app.serenyx.com',
        'https://serenyx-app.vercel.app',
        'https://serenyx-app.netlify.app',
        // Add your Flutter app domains when deployed
        'capacitor://localhost',
        'ionic://localhost',
      ]
    : [
        'http://localhost:3000',
        'http://localhost:8080',
        'http://localhost:4200',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:8080',
        'capacitor://localhost',
        'ionic://localhost',
      ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Requested-With',
    'Accept',
    'Origin',
    'X-API-Key',
  ],
  exposedHeaders: ['X-Total-Count', 'X-Page-Count'],
  maxAge: 86400, // 24 hours
};

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.elevenlabs.io"],
      mediaSrc: ["'self'", "https:"],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: isProduction ? [] : null,
    },
  },
  crossOriginEmbedderPolicy: false,
}));

// CORS
app.use(cors(corsOptions));

// Compression
app.use(compression({
  level: 6,
  threshold: 1024,
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  },
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
if (isProduction) {
  app.use(morgan('combined', {
    stream: {
      write: (message) => logger.info(message.trim()),
    },
  }));
} else {
  app.use(morgan('dev'));
}

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: isProduction ? 100 : 1000, // limit each IP to 100 requests per windowMs in production
  message: {
    error: 'Too many requests from this IP, please try again later.',
    retryAfter: '15 minutes',
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn(`Rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      error: 'Too many requests from this IP, please try again later.',
      retryAfter: '15 minutes',
    });
  },
});

// Speed limiting
const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000, // 15 minutes
  delayAfter: isProduction ? 50 : 500, // allow 50 requests per 15 minutes in production
  delayMs: 500, // begin adding 500ms of delay per request above 50
  maxDelayMs: 20000, // maximum delay of 20 seconds
});

// Apply rate limiting to all routes
app.use(limiter);
app.use(speedLimiter);

// Audit logging
app.use(auditLogger);

// Initialize Firebase
initializeFirebase();

// Health check route (no auth required)
app.use('/api/health', healthRoutes);

// Public routes (no auth required)
app.use('/api/auth', authRoutes);
app.use('/api/voice', voiceRoutes);

// Protected routes (auth required)
app.use('/api/pets', authMiddleware, petRoutes);
app.use('/api/soundscape', authMiddleware, soundscapeRoutes);
app.use('/api/voting', authMiddleware, votingRoutes);
app.use('/api/users', authMiddleware, userRoutes);
app.use('/api/gamification', authMiddleware, gamificationRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'Serenyx Pet Wellness API',
    version: '1.0.0',
    environment: NODE_ENV,
    timestamp: new Date().toISOString(),
    status: 'healthy',
    documentation: '/api/docs',
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl,
    method: req.method,
  });
});

// Global error handler
app.use(errorHandler);

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  process.exit(0);
});

// Unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

// Start server
app.listen(PORT, () => {
  logger.info(`🚀 Serenyx API Server running on port ${PORT}`);
  logger.info(`🌍 Environment: ${NODE_ENV}`);
  logger.info(`📊 Health check: http://localhost:${PORT}/api/health`);
  
  if (isProduction) {
    logger.info('🔒 Production mode enabled');
    logger.info('🛡️ Security features active');
  } else {
    logger.info('🔧 Development mode enabled');
    logger.info('📝 Debug logging active');
  }
});

export default app;