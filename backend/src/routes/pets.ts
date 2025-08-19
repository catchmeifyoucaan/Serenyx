import { Router } from 'express';
import { getFirestore } from '../services/firebase';
import { createPetSchema, updatePetSchema } from '../models/validation';
import { asyncHandler } from '../middleware/errorHandler';
import { logAudit } from '../utils/logger';
import { ValidationError, NotFoundError } from '../middleware/errorHandler';

const router = Router();

// Get all pets for current user
router.get('/', asyncHandler(async (req, res) => {
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

  logAudit(req.user.uid, 'GET_PETS', 'pets', { count: pets.length });

  res.json({
    pets,
    count: pets.length,
  });
}));

// Get a specific pet
router.get('/:petId', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const { petId } = req.params;
  const db = getFirestore();
  const petDoc = await db.collection('pets').doc(petId).get();

  if (!petDoc.exists) {
    throw new NotFoundError('Pet not found');
  }

  const petData = petDoc.data();
  if (petData?.ownerId !== req.user.uid) {
    throw new ValidationError('Access denied');
  }

  logAudit(req.user.uid, 'GET_PET', 'pets', { petId });

  res.json({
    id: petDoc.id,
    ...petData,
  });
}));

// Create a new pet
router.post('/', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const validatedData = createPetSchema.parse(req.body);
  const db = getFirestore();

  const petData = {
    ...validatedData,
    ownerId: req.user.uid,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  const docRef = await db.collection('pets').add(petData);
  const newPet = await docRef.get();

  logAudit(req.user.uid, 'CREATE_PET', 'pets', { petId: docRef.id });

  res.status(201).json({
    id: docRef.id,
    ...newPet.data(),
  });
}));

// Update a pet
router.put('/:petId', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const { petId } = req.params;
  const validatedData = updatePetSchema.parse(req.body);
  const db = getFirestore();

  // Check if pet exists and user owns it
  const petDoc = await db.collection('pets').doc(petId).get();
  if (!petDoc.exists) {
    throw new NotFoundError('Pet not found');
  }

  const petData = petDoc.data();
  if (petData?.ownerId !== req.user.uid) {
    throw new ValidationError('Access denied');
  }

  const updateData = {
    ...validatedData,
    updatedAt: new Date().toISOString(),
  };

  await db.collection('pets').doc(petId).update(updateData);
  const updatedPet = await db.collection('pets').doc(petId).get();

  logAudit(req.user.uid, 'UPDATE_PET', 'pets', { petId });

  res.json({
    id: petId,
    ...updatedPet.data(),
  });
}));

// Delete a pet
router.delete('/:petId', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const { petId } = req.params;
  const db = getFirestore();

  // Check if pet exists and user owns it
  const petDoc = await db.collection('pets').doc(petId).get();
  if (!petDoc.exists) {
    throw new NotFoundError('Pet not found');
  }

  const petData = petDoc.data();
  if (petData?.ownerId !== req.user.uid) {
    throw new ValidationError('Access denied');
  }

  await db.collection('pets').doc(petId).delete();

  logAudit(req.user.uid, 'DELETE_PET', 'pets', { petId });

  res.status(204).send();
}));

export default router;