import { Router } from 'express';
import { createCustomToken, getUserByUid } from '../services/firebase';
import { asyncHandler } from '../middleware/errorHandler';
import { logAudit } from '../utils/logger';

const router = Router();

// Get current user info
router.get('/me', asyncHandler(async (req, res) => {
  if (!req.user) {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'No user found',
    });
  }

  try {
    const userRecord = await getUserByUid(req.user.uid);
    
    logAudit(req.user.uid, 'GET_USER_INFO', 'auth', {
      email: userRecord.email,
    });

    res.json({
      uid: userRecord.uid,
      email: userRecord.email,
      emailVerified: userRecord.emailVerified,
      displayName: userRecord.displayName,
      photoURL: userRecord.photoURL,
      createdAt: userRecord.metadata.creationTime,
      lastSignInAt: userRecord.metadata.lastSignInTime,
    });
  } catch (error) {
    res.status(404).json({
      error: 'User not found',
      message: 'User record not found in Firebase',
    });
  }
}));

// Create custom token
router.post('/token', asyncHandler(async (req, res) => {
  if (!req.user) {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Authentication required',
    });
  }

  try {
    const customToken = await createCustomToken(req.user.uid);
    
    logAudit(req.user.uid, 'CREATE_CUSTOM_TOKEN', 'auth');

    res.json({
      token: customToken,
      expiresIn: 3600, // 1 hour
    });
  } catch (error) {
    res.status(500).json({
      error: 'Token creation failed',
      message: 'Failed to create custom token',
    });
  }
}));

export default router;