import admin from 'firebase-admin';
import { logger } from '../utils/logger';

let firebaseApp: admin.app.App;

export const initializeFirebase = (): void => {
  try {
    // Check if Firebase is already initialized
    if (admin.apps.length > 0) {
      firebaseApp = admin.apps[0]!;
      logger.info('Firebase already initialized');
      return;
    }

    // Initialize Firebase Admin SDK
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      }),
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    });

    logger.info('✅ Firebase initialized successfully');
  } catch (error) {
    logger.error('❌ Failed to initialize Firebase:', error);
    throw error;
  }
};

export const getFirestore = (): admin.firestore.Firestore => {
  if (!firebaseApp) {
    throw new Error('Firebase not initialized');
  }
  return firebaseApp.firestore();
};

export const getStorage = (): admin.storage.Storage => {
  if (!firebaseApp) {
    throw new Error('Firebase not initialized');
  }
  return firebaseApp.storage();
};

export const getAuth = (): admin.auth.Auth => {
  if (!firebaseApp) {
    throw new Error('Firebase not initialized');
  }
  return firebaseApp.auth();
};

export const verifyIdToken = async (idToken: string): Promise<admin.auth.DecodedIdToken> => {
  try {
    const auth = getAuth();
    const decodedToken = await auth.verifyIdToken(idToken);
    return decodedToken;
  } catch (error) {
    logger.error('Error verifying ID token:', error);
    throw new Error('Invalid authentication token');
  }
};

export const getUserByUid = async (uid: string): Promise<admin.auth.UserRecord> => {
  try {
    const auth = getAuth();
    const userRecord = await auth.getUser(uid);
    return userRecord;
  } catch (error) {
    logger.error('Error getting user by UID:', error);
    throw new Error('User not found');
  }
};

export const createCustomToken = async (uid: string, additionalClaims?: object): Promise<string> => {
  try {
    const auth = getAuth();
    const customToken = await auth.createCustomToken(uid, additionalClaims);
    return customToken;
  } catch (error) {
    logger.error('Error creating custom token:', error);
    throw new Error('Failed to create custom token');
  }
};