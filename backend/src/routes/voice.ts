import express from 'express';
import { asyncHandler } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { getFirestore } from '../services/firebase';
import { ValidationError } from '../middleware/errorHandler';
import { z } from 'zod';
import axios from 'axios';

const router = express.Router();

// Voice guidance schemas
const textToSpeechSchema = z.object({
  text: z.string().min(1).max(500),
  voice: z.string().optional(),
  speed: z.number().min(0.5).max(2.0).optional(),
  pitch: z.number().min(-20).max(20).optional(),
  language: z.string().optional(),
});

const voiceCommandSchema = z.object({
  command: z.string().min(1).max(100),
  context: z.string().optional(),
  userId: z.string().optional(),
});

const audioFeedbackSchema = z.object({
  type: z.enum(['success', 'error', 'warning', 'info', 'celebration']),
  message: z.string().min(1).max(200),
  duration: z.number().min(1000).max(10000).optional(),
});

// ElevenLabs API configuration
const ELEVENLABS_API_KEY = process.env.ELEVENLABS_API_KEY;
const ELEVENLABS_BASE_URL = 'https://api.elevenlabs.io/v1';

/**
 * @route POST /api/voice/text-to-speech
 * @desc Convert text to speech using ElevenLabs
 * @access Public
 */
router.post('/text-to-speech', asyncHandler(async (req, res) => {
  try {
    const { text, voice = 'pNInz6obpgDQGcFmaJgB', speed = 1.0, pitch = 0, language = 'en' } = textToSpeechSchema.parse(req.body);

    if (!ELEVENLABS_API_KEY) {
      throw new ValidationError('ElevenLabs API key not configured');
    }

    // Call ElevenLabs API
    const response = await axios.post(
      `${ELEVENLABS_BASE_URL}/text-to-speech/${voice}`,
      {
        text,
        model_id: 'eleven_monolingual_v1',
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.5,
          style: 0.0,
          use_speaker_boost: true,
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

    // Convert audio buffer to base64
    const audioBuffer = Buffer.from(response.data);
    const base64Audio = audioBuffer.toString('base64');

    // Log the request
    logger.info(`Text-to-speech generated: "${text.substring(0, 50)}..."`);

    res.json({
      success: true,
      audio: base64Audio,
      format: 'mp3',
      duration: response.headers['x-audio-duration'] || 'unknown',
      text,
      voice,
      speed,
      pitch,
      language,
    });
  } catch (error) {
    logger.error('Text-to-speech error:', error);
    throw error;
  }
}));

/**
 * @route GET /api/voice/voices
 * @desc Get available voices from ElevenLabs
 * @access Public
 */
router.get('/voices', asyncHandler(async (req, res) => {
  try {
    if (!ELEVENLABS_API_KEY) {
      throw new ValidationError('ElevenLabs API key not configured');
    }

    const response = await axios.get(`${ELEVENLABS_BASE_URL}/voices`, {
      headers: {
        'xi-api-key': ELEVENLABS_API_KEY,
      },
    });

    const voices = response.data.voices.map((voice: any) => ({
      id: voice.voice_id,
      name: voice.name,
      category: voice.category,
      description: voice.description,
      labels: voice.labels,
      preview_url: voice.preview_url,
      settings: voice.settings,
    }));

    res.json({
      success: true,
      voices,
      count: voices.length,
    });
  } catch (error) {
    logger.error('Get voices error:', error);
    throw error;
  }
}));

/**
 * @route POST /api/voice/command
 * @desc Process voice commands and return appropriate responses
 * @access Public
 */
router.post('/command', asyncHandler(async (req, res) => {
  try {
    const { command, context, userId } = voiceCommandSchema.parse(req.body);

    // Process voice command
    const response = await processVoiceCommand(command, context, userId);

    res.json({
      success: true,
      command,
      response,
      context,
    });
  } catch (error) {
    logger.error('Voice command error:', error);
    throw error;
  }
}));

/**
 * @route POST /api/voice/feedback
 * @desc Generate audio feedback for different scenarios
 * @access Public
 */
router.post('/feedback', asyncHandler(async (req, res) => {
  try {
    const { type, message, duration = 3000 } = audioFeedbackSchema.parse(req.body);

    // Generate appropriate feedback message
    const feedbackMessage = generateFeedbackMessage(type, message);

    // Get appropriate voice for feedback type
    const voice = getVoiceForFeedbackType(type);

    // Generate speech
    const speechResponse = await axios.post(
      `${ELEVENLABS_BASE_URL}/text-to-speech/${voice}`,
      {
        text: feedbackMessage,
        model_id: 'eleven_monolingual_v1',
        voice_settings: {
          stability: 0.7,
          similarity_boost: 0.7,
          style: 0.0,
          use_speaker_boost: true,
        },
      },
      {
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': ELEVENLABS_API_KEY!,
        },
        responseType: 'arraybuffer',
      }
    );

    const audioBuffer = Buffer.from(speechResponse.data);
    const base64Audio = audioBuffer.toString('base64');

    res.json({
      success: true,
      type,
      message: feedbackMessage,
      audio: base64Audio,
      duration,
      format: 'mp3',
    });
  } catch (error) {
    logger.error('Audio feedback error:', error);
    throw error;
  }
}));

/**
 * @route POST /api/voice/onboarding
 * @desc Generate voice guidance for onboarding steps
 * @access Public
 */
router.post('/onboarding', asyncHandler(async (req, res) => {
  try {
    const { step, petName, personalityType } = req.body;

    const onboardingMessages = {
      welcome: `Welcome to Serenyx! I'm here to help you give your pet the best care possible. Let's start this amazing journey together.`,
      petType: `What type of pet do you have? I'll customize everything just for them.`,
      petName: `What's your pet's name? I love getting to know each furry friend personally.`,
      personality: `Let's discover what makes ${petName} special. I'll ask a few questions to understand their unique personality.`,
      goals: `What are your main goals for ${petName}? Whether it's health, training, or just more quality time, I'm here to help.`,
      complete: `Perfect! ${petName} is now part of the Serenyx family. I'm excited to help you both on this wellness journey!`,
    };

    const message = onboardingMessages[step as keyof typeof onboardingMessages] || onboardingMessages.welcome;

    // Generate speech with warm, friendly voice
    const speechResponse = await axios.post(
      `${ELEVENLABS_BASE_URL}/text-to-speech/pNInz6obpgDQGcFmaJgB`, // Warm, friendly voice
      {
        text: message,
        model_id: 'eleven_monolingual_v1',
        voice_settings: {
          stability: 0.8,
          similarity_boost: 0.8,
          style: 0.0,
          use_speaker_boost: true,
        },
      },
      {
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': ELEVENLABS_API_KEY!,
        },
        responseType: 'arraybuffer',
      }
    );

    const audioBuffer = Buffer.from(speechResponse.data);
    const base64Audio = audioBuffer.toString('base64');

    res.json({
      success: true,
      step,
      message,
      audio: base64Audio,
      format: 'mp3',
    });
  } catch (error) {
    logger.error('Onboarding voice error:', error);
    throw error;
  }
}));

/**
 * @route POST /api/voice/achievement
 * @desc Generate voice celebration for achievements
 * @access Public
 */
router.post('/achievement', asyncHandler(async (req, res) => {
  try {
    const { achievementTitle, petName, rarity } = req.body;

    const celebrationMessages = {
      common: `Great job! You've unlocked the ${achievementTitle} achievement. ${petName} is doing amazing!`,
      uncommon: `Excellent work! The ${achievementTitle} achievement is yours. ${petName} is really thriving!`,
      rare: `Incredible! You've earned the rare ${achievementTitle} achievement. ${petName} is absolutely outstanding!`,
      epic: `Fantastic! The epic ${achievementTitle} achievement is now yours. ${petName} is truly exceptional!`,
      legendary: `Legendary! You've achieved the legendary ${achievementTitle}. ${petName} is absolutely legendary!`,
    };

    const message = celebrationMessages[rarity as keyof typeof celebrationMessages] || celebrationMessages.common;

    // Generate speech with excited, celebratory voice
    const speechResponse = await axios.post(
      `${ELEVENLABS_BASE_URL}/text-to-speech/pNInz6obpgDQGcFmaJgB`,
      {
        text: message,
        model_id: 'eleven_monolingual_v1',
        voice_settings: {
          stability: 0.6,
          similarity_boost: 0.8,
          style: 0.3, // More expressive
          use_speaker_boost: true,
        },
      },
      {
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': ELEVENLABS_API_KEY!,
        },
        responseType: 'arraybuffer',
      }
    );

    const audioBuffer = Buffer.from(speechResponse.data);
    const base64Audio = audioBuffer.toString('base64');

    res.json({
      success: true,
      achievementTitle,
      message,
      audio: base64Audio,
      format: 'mp3',
      rarity,
    });
  } catch (error) {
    logger.error('Achievement voice error:', error);
    throw error;
  }
}));

/**
 * @route POST /api/voice/health-reminder
 * @desc Generate voice reminders for pet health tasks
 * @access Public
 */
router.post('/health-reminder', asyncHandler(async (req, res) => {
  try {
    const { task, petName, time } = req.body;

    const reminderMessages = {
      feeding: `Time to feed ${petName}! They're probably getting hungry.`,
      medication: `Don't forget ${petName}'s medication. Their health comes first!`,
      exercise: `It's exercise time for ${petName}! Let's get them moving and happy.`,
      grooming: `Time for ${petName}'s grooming session. They'll feel so much better!`,
      vet: `Don't forget ${petName}'s vet appointment. Keeping them healthy is our priority!`,
    };

    const message = reminderMessages[task as keyof typeof reminderMessages] || `Time for ${petName}'s ${task}!`;

    // Generate speech with caring, gentle voice
    const speechResponse = await axios.post(
      `${ELEVENLABS_BASE_URL}/text-to-speech/pNInz6obpgDQGcFmaJgB`,
      {
        text: message,
        model_id: 'eleven_monolingual_v1',
        voice_settings: {
          stability: 0.9,
          similarity_boost: 0.7,
          style: 0.0,
          use_speaker_boost: true,
        },
      },
      {
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': ELEVENLABS_API_KEY!,
        },
        responseType: 'arraybuffer',
      }
    );

    const audioBuffer = Buffer.from(speechResponse.data);
    const base64Audio = audioBuffer.toString('base64');

    res.json({
      success: true,
      task,
      message,
      audio: base64Audio,
      format: 'mp3',
      time,
    });
  } catch (error) {
    logger.error('Health reminder voice error:', error);
    throw error;
  }
}));

// Helper functions
async function processVoiceCommand(command: string, context?: string, userId?: string) {
  const lowerCommand = command.toLowerCase();
  
  // Simple command processing
  if (lowerCommand.includes('hello') || lowerCommand.includes('hi')) {
    return {
      type: 'greeting',
      message: 'Hello! How can I help you and your pet today?',
      action: 'greet',
    };
  }
  
  if (lowerCommand.includes('feed') || lowerCommand.includes('food')) {
    return {
      type: 'feeding',
      message: 'Time to feed your pet! Make sure they have fresh water too.',
      action: 'feeding_reminder',
    };
  }
  
  if (lowerCommand.includes('walk') || lowerCommand.includes('exercise')) {
    return {
      type: 'exercise',
      message: 'Great idea! Exercise is important for your pet\'s health and happiness.',
      action: 'exercise_reminder',
    };
  }
  
  if (lowerCommand.includes('health') || lowerCommand.includes('vet')) {
    return {
      type: 'health',
      message: 'Your pet\'s health is our priority. Would you like to schedule a check-up?',
      action: 'health_check',
    };
  }
  
  return {
    type: 'general',
    message: 'I heard you say something about your pet. How can I help?',
    action: 'general_help',
  };
}

function generateFeedbackMessage(type: string, message: string): string {
  const feedbackPrefixes = {
    success: 'Great! ',
    error: 'Oops! ',
    warning: 'Heads up! ',
    info: 'Did you know? ',
    celebration: '🎉 ',
  };
  
  return `${feedbackPrefixes[type as keyof typeof feedbackPrefixes] || ''}${message}`;
}

function getVoiceForFeedbackType(type: string): string {
  const voiceMap = {
    success: 'pNInz6obpgDQGcFmaJgB', // Warm, friendly
    error: 'pNInz6obpgDQGcFmaJgB', // Same voice, different tone
    warning: 'pNInz6obpgDQGcFmaJgB', // Caring, gentle
    info: 'pNInz6obpgDQGcFmaJgB', // Informative, clear
    celebration: 'pNInz6obpgDQGcFmaJgB', // Excited, joyful
  };
  
  return voiceMap[type as keyof typeof voiceMap] || 'pNInz6obpgDQGcFmaJgB';
}

export default router;