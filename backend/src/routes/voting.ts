import { Router } from 'express';
import { getFirestore } from '../services/firebase';
import { voteSchema, submitPetSchema } from '../models/validation';
import { asyncHandler } from '../middleware/errorHandler';
import { logAudit } from '../utils/logger';
import { ValidationError, NotFoundError, ConflictError } from '../middleware/errorHandler';

const router = Router();

// Get all best pet entries
router.get('/', asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { category, timeFrame = 'all' } = req.query;

  let query = db.collection('bestPetEntries').orderBy('votes', 'desc');

  if (category && category !== 'all') {
    query = query.where('category', '==', category);
  }

  if (timeFrame === 'monthly') {
    const monthAgo = new Date();
    monthAgo.setMonth(monthAgo.getMonth() - 1);
    query = query.where('createdAt', '>=', monthAgo.toISOString());
  } else if (timeFrame === 'weekly') {
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    query = query.where('createdAt', '>=', weekAgo.toISOString());
  }

  const snapshot = await query.limit(50).get();
  const entries = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  res.json({
    entries,
    count: entries.length,
  });
}));

// Submit a pet for the contest
router.post('/submit', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const validatedData = submitPetSchema.parse(req.body);
  const db = getFirestore();

  // Check if pet exists and user owns it
  const petDoc = await db.collection('pets').doc(validatedData.petId).get();
  if (!petDoc.exists) {
    throw new NotFoundError('Pet not found');
  }

  const petData = petDoc.data();
  if (petData?.ownerId !== req.user.uid) {
    throw new ValidationError('Access denied - you can only submit your own pets');
  }

  // Check if pet is already submitted in this category
  const existingEntry = await db
    .collection('bestPetEntries')
    .where('petId', '==', validatedData.petId)
    .where('category', '==', validatedData.category)
    .get();

  if (!existingEntry.empty) {
    throw new ConflictError('Pet already submitted in this category');
  }

  const entryData = {
    ...validatedData,
    ownerId: req.user.uid,
    votes: 0,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  const docRef = await db.collection('bestPetEntries').add(entryData);
  const newEntry = await docRef.get();

  logAudit(req.user.uid, 'SUBMIT_PET', 'voting', { 
    petId: validatedData.petId,
    category: validatedData.category,
    entryId: docRef.id,
  });

  res.status(201).json({
    id: docRef.id,
    ...newEntry.data(),
  });
}));

// Vote for a pet
router.post('/vote', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const validatedData = voteSchema.parse(req.body);
  const db = getFirestore();

  // Check if entry exists
  const entryQuery = await db
    .collection('bestPetEntries')
    .where('petId', '==', validatedData.petId)
    .where('category', '==', validatedData.category)
    .get();

  if (entryQuery.empty) {
    throw new NotFoundError('Pet entry not found in this category');
  }

  const entryDoc = entryQuery.docs[0];
  const entryData = entryDoc.data();

  // Check if user already voted for this pet in this category today
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const voteQuery = await db
    .collection('votes')
    .where('userId', '==', req.user.uid)
    .where('entryId', '==', entryDoc.id)
    .where('createdAt', '>=', today.toISOString())
    .get();

  if (!voteQuery.empty) {
    throw new ConflictError('You have already voted for this pet today');
  }

  // Record the vote
  const voteData = {
    userId: req.user.uid,
    entryId: entryDoc.id,
    petId: validatedData.petId,
    category: validatedData.category,
    reason: validatedData.reason,
    createdAt: new Date().toISOString(),
  };

  await db.collection('votes').add(voteData);

  // Update vote count
  await db.collection('bestPetEntries').doc(entryDoc.id).update({
    votes: entryData.votes + 1,
    updatedAt: new Date().toISOString(),
  });

  logAudit(req.user.uid, 'VOTE_PET', 'voting', { 
    petId: validatedData.petId,
    category: validatedData.category,
    entryId: entryDoc.id,
  });

  res.json({
    message: 'Vote recorded successfully',
    newVoteCount: entryData.votes + 1,
  });
}));

// Get user's voting history
router.get('/history', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const db = getFirestore();
  const votesQuery = await db
    .collection('votes')
    .where('userId', '==', req.user.uid)
    .orderBy('createdAt', 'desc')
    .limit(20)
    .get();

  const votes = votesQuery.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  res.json({
    votes,
    count: votes.length,
  });
}));

// Get contest statistics
router.get('/stats', asyncHandler(async (req, res) => {
  const db = getFirestore();
  
  const [entriesSnapshot, votesSnapshot] = await Promise.all([
    db.collection('bestPetEntries').get(),
    db.collection('votes').get(),
  ]);

  const totalEntries = entriesSnapshot.size;
  const totalVotes = votesSnapshot.size;

  // Get category breakdown
  const categoryStats: Record<string, number> = {};
  entriesSnapshot.docs.forEach(doc => {
    const category = doc.data().category;
    categoryStats[category] = (categoryStats[category] || 0) + 1;
  });

  res.json({
    totalEntries,
    totalVotes,
    categoryStats,
    timestamp: new Date().toISOString(),
  });
}));

export default router;