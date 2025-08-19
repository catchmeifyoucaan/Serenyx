import { Router } from 'express';
import { getFirestore } from '../services/firebase';
import { updateUserSchema } from '../models/validation';
import { asyncHandler } from '../middleware/errorHandler';
import { logAudit } from '../utils/logger';
import { ValidationError, NotFoundError } from '../middleware/errorHandler';

const router = Router();

// Get current user profile
router.get('/profile', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const db = getFirestore();
  const userDoc = await db.collection('users').doc(req.user.uid).get();

  if (!userDoc.exists) {
    // Create user profile if it doesn't exist
    const userData = {
      uid: req.user.uid,
      email: req.user.email,
      emailVerified: req.user.emailVerified,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    await db.collection('users').doc(req.user.uid).set(userData);

    logAudit(req.user.uid, 'CREATE_USER_PROFILE', 'users');

    res.json(userData);
  } else {
    logAudit(req.user.uid, 'GET_USER_PROFILE', 'users');

    res.json({
      id: userDoc.id,
      ...userDoc.data(),
    });
  }
}));

// Update user profile
router.put('/profile', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const validatedData = updateUserSchema.parse(req.body);
  const db = getFirestore();

  const updateData = {
    ...validatedData,
    updatedAt: new Date().toISOString(),
  };

  await db.collection('users').doc(req.user.uid).update(updateData);
  const updatedUser = await db.collection('users').doc(req.user.uid).get();

  logAudit(req.user.uid, 'UPDATE_USER_PROFILE', 'users', { fields: Object.keys(validatedData) });

  res.json({
    id: updatedUser.id,
    ...updatedUser.data(),
  });
}));

// Get user statistics
router.get('/stats', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const db = getFirestore();

  // Get counts from different collections
  const [petsSnapshot, soundscapesSnapshot, votesSnapshot] = await Promise.all([
    db.collection('pets').where('ownerId', '==', req.user.uid).get(),
    db.collection('soundscapes').where('ownerId', '==', req.user.uid).get(),
    db.collection('votes').where('userId', '==', req.user.uid).get(),
  ]);

  const stats = {
    pets: petsSnapshot.size,
    soundscapes: soundscapesSnapshot.size,
    votesCast: votesSnapshot.size,
    createdAt: new Date().toISOString(),
  };

  logAudit(req.user.uid, 'GET_USER_STATS', 'users', stats);

  res.json(stats);
}));

// Get user's pets
router.get('/pets', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const db = getFirestore();
  const petsRef = db.collection('pets').where('ownerId', '==', req.user.uid);
  const snapshot = await petsRef.get();

  const pets = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  logAudit(req.user.uid, 'GET_USER_PETS', 'users', { count: pets.length });

  res.json({
    pets,
    count: pets.length,
  });
}));

// Get user's soundscapes
router.get('/soundscapes', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const db = getFirestore();
  const soundscapesRef = db.collection('soundscapes').where('ownerId', '==', req.user.uid);
  const snapshot = await soundscapesRef.get();

  const soundscapes = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  logAudit(req.user.uid, 'GET_USER_SOUNDSCAPES', 'users', { count: soundscapes.length });

  res.json({
    soundscapes,
    count: soundscapes.length,
  });
}));

// Get user's voting history
router.get('/votes', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const db = getFirestore();
  const votesRef = db.collection('votes').where('userId', '==', req.user.uid);
  const snapshot = await votesRef.orderBy('createdAt', 'desc').limit(50).get();

  const votes = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  logAudit(req.user.uid, 'GET_USER_VOTES', 'users', { count: votes.length });

  res.json({
    votes,
    count: votes.length,
  });
}));

// Delete user account (soft delete)
router.delete('/account', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const db = getFirestore();

  // Mark user as deleted
  await db.collection('users').doc(req.user.uid).update({
    deletedAt: new Date().toISOString(),
    isDeleted: true,
  });

  logAudit(req.user.uid, 'DELETE_USER_ACCOUNT', 'users');

  res.json({
    message: 'Account marked for deletion',
    timestamp: new Date().toISOString(),
  });
}));

export default router;