import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';
import { initializeApp, applicationDefault, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { bestPetRouter } from './routes/bestPet.js';
import { soundscapeRouter } from './routes/soundscape.js';

dotenv.config();

// Firebase Admin init
if (!process.env.GOOGLE_APPLICATION_CREDENTIALS && process.env.FIREBASE_SERVICE_ACCOUNT) {
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  initializeApp({
    credential: cert(serviceAccount),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  });
} else {
  initializeApp({
    credential: applicationDefault(),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  });
}

const app = express();
app.use(helmet());
app.use(cors({ origin: true }));
app.use(express.json({ limit: '2mb' }));
app.use(morgan('combined'));

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(apiLimiter);

// Auth middleware
app.use(async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.substring(7) : undefined;
    if (!token) return res.status(401).json({ error: 'Missing token' });
    const decoded = await getAuth().verifyIdToken(token);
    (req as any).user = decoded;
    return next();
  } catch (e) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
});

// Audit logging middleware
app.use(async (req: Request, _res: Response, next: NextFunction) => {
  try {
    const db = getFirestore();
    const user = (req as any).user;
    await db.collection('audit_logs').add({
      uid: user?.uid || null,
      path: req.path,
      method: req.method,
      ts: new Date().toISOString(),
      ip: (req.headers['x-forwarded-for'] || req.socket.remoteAddress || '') as string,
    });
  } catch {}
  next();
});

app.get('/health', (_req, res) => res.json({ ok: true }));

app.use('/best-pet', bestPetRouter);
app.use('/soundscape', soundscapeRouter);

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`API listening on :${port}`);
});

