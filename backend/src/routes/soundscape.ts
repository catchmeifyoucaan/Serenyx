import { Router } from 'express';
import { getFirestore } from '../services/firebase';
import { createSoundscapeSchema, updateSoundscapeSchema } from '../models/validation';
import { asyncHandler } from '../middleware/errorHandler';
import { logAudit } from '../utils/logger';
import { ValidationError, NotFoundError } from '../middleware/errorHandler';
import axios from 'axios';

const router = Router();

// ElevenLabs API configuration
const ELEVENLABS_API_KEY = process.env.ELEVENLABS_API_KEY;
const ELEVENLABS_BASE_URL = process.env.ELEVENLABS_BASE_URL || 'https://api.elevenlabs.io/v1';

// Get all soundscapes for current user
router.get('/', asyncHandler(async (req, res) => {
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

  logAudit(req.user.uid, 'GET_SOUNDSCAPES', 'soundscape', { count: soundscapes.length });

  res.json({
    soundscapes,
    count: soundscapes.length,
  });
}));

// Get public soundscapes
router.get('/public', asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { category, limit = 20 } = req.query;

  let query = db.collection('soundscapes')
    .where('isPublic', '==', true)
    .orderBy('createdAt', 'desc');

  if (category && category !== 'all') {
    query = query.where('category', '==', category);
  }

  const snapshot = await query.limit(Number(limit)).get();
  const soundscapes = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  res.json({
    soundscapes,
    count: soundscapes.length,
  });
}));

// Create a new soundscape
router.post('/', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const validatedData = createSoundscapeSchema.parse(req.body);
  const db = getFirestore();

  const soundscapeData = {
    ...validatedData,
    ownerId: req.user.uid,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  const docRef = await db.collection('soundscapes').add(soundscapeData);
  const newSoundscape = await docRef.get();

  logAudit(req.user.uid, 'CREATE_SOUNDSCAPE', 'soundscape', { soundscapeId: docRef.id });

  res.status(201).json({
    id: docRef.id,
    ...newSoundscape.data(),
  });
}));

// Generate soundscape using ElevenLabs
router.post('/generate', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  if (!ELEVENLABS_API_KEY) {
    throw new ValidationError('ElevenLabs API key not configured');
  }

  const { text, voiceId = '21m00Tcm4TlvDq8ikWAM', modelId = 'eleven_monolingual_v1' } = req.body;

  if (!text) {
    throw new ValidationError('Text is required for soundscape generation');
  }

  try {
    // Call ElevenLabs API
    const response = await axios.post(
      `${ELEVENLABS_BASE_URL}/text-to-speech/${voiceId}`,
      {
        text,
        model_id: modelId,
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.5,
        },
      },
      {
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': ELEVENLABS_API_KEY,
        },
        responseType: 'arraybuffer',
      }
    );

    // Store the audio in Firebase Storage
    const storage = getFirestore().app.storage();
    const bucket = storage.bucket();
    const fileName = `soundscapes/${req.user.uid}/${Date.now()}.mp3`;
    const file = bucket.file(fileName);

    await file.save(response.data, {
      metadata: {
        contentType: 'audio/mpeg',
      },
    });

    // Get the public URL
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: '03-01-2500', // Far future expiration
    });

    // Save soundscape metadata to Firestore
    const soundscapeData = {
      name: `Generated Soundscape - ${new Date().toLocaleString()}`,
      description: `AI-generated soundscape from text: "${text.substring(0, 100)}..."`,
      category: 'custom',
      duration: 0, // Will be calculated from audio file
      audioUrl: url,
      text: text,
      voiceId: voiceId,
      modelId: modelId,
      ownerId: req.user.uid,
      isPublic: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const docRef = await getFirestore().collection('soundscapes').add(soundscapeData);
    const newSoundscape = await docRef.get();

    logAudit(req.user.uid, 'GENERATE_SOUNDSCAPE', 'soundscape', { 
      soundscapeId: docRef.id,
      voiceId,
      textLength: text.length,
    });

    res.status(201).json({
      id: docRef.id,
      ...newSoundscape.data(),
    });

  } catch (error) {
    console.error('ElevenLabs API error:', error);
    throw new ValidationError('Failed to generate soundscape');
  }
}));

// Get available voices from ElevenLabs
router.get('/voices', asyncHandler(async (req, res) => {
  if (!ELEVENLABS_API_KEY) {
    throw new ValidationError('ElevenLabs API key not configured');
  }

  try {
    const response = await axios.get(`${ELEVENLABS_BASE_URL}/voices`, {
      headers: {
        'xi-api-key': ELEVENLABS_API_KEY,
      },
    });

    res.json({
      voices: response.data.voices,
      count: response.data.voices.length,
    });
  } catch (error) {
    console.error('ElevenLabs voices API error:', error);
    throw new ValidationError('Failed to fetch voices');
  }
}));

// Update a soundscape
router.put('/:soundscapeId', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const { soundscapeId } = req.params;
  const validatedData = updateSoundscapeSchema.parse(req.body);
  const db = getFirestore();

  // Check if soundscape exists and user owns it
  const soundscapeDoc = await db.collection('soundscapes').doc(soundscapeId).get();
  if (!soundscapeDoc.exists) {
    throw new NotFoundError('Soundscape not found');
  }

  const soundscapeData = soundscapeDoc.data();
  if (soundscapeData?.ownerId !== req.user.uid) {
    throw new ValidationError('Access denied');
  }

  const updateData = {
    ...validatedData,
    updatedAt: new Date().toISOString(),
  };

  await db.collection('soundscapes').doc(soundscapeId).update(updateData);
  const updatedSoundscape = await db.collection('soundscapes').doc(soundscapeId).get();

  logAudit(req.user.uid, 'UPDATE_SOUNDSCAPE', 'soundscape', { soundscapeId });

  res.json({
    id: soundscapeId,
    ...updatedSoundscape.data(),
  });
}));

// Delete a soundscape
router.delete('/:soundscapeId', asyncHandler(async (req, res) => {
  if (!req.user) {
    throw new ValidationError('User not authenticated');
  }

  const { soundscapeId } = req.params;
  const db = getFirestore();

  // Check if soundscape exists and user owns it
  const soundscapeDoc = await db.collection('soundscapes').doc(soundscapeId).get();
  if (!soundscapeDoc.exists) {
    throw new NotFoundError('Soundscape not found');
  }

  const soundscapeData = soundscapeDoc.data();
  if (soundscapeData?.ownerId !== req.user.uid) {
    throw new ValidationError('Access denied');
  }

  // Delete from Firestore
  await db.collection('soundscapes').doc(soundscapeId).delete();

  // Delete audio file from Storage if it exists
  if (soundscapeData.audioUrl) {
    try {
      const storage = db.app.storage();
      const bucket = storage.bucket();
      const fileName = soundscapeData.audioUrl.split('/').pop();
      if (fileName) {
        await bucket.file(`soundscapes/${req.user.uid}/${fileName}`).delete();
      }
    } catch (error) {
      console.error('Failed to delete audio file:', error);
    }
  }

  logAudit(req.user.uid, 'DELETE_SOUNDSCAPE', 'soundscape', { soundscapeId });

  res.status(204).send();
}));

export default router;