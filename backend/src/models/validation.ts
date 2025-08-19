import { z } from 'zod';

// Pet validation schemas
export const createPetSchema = z.object({
  name: z.string().min(1, 'Name is required').max(50, 'Name too long'),
  type: z.enum(['Dog', 'Cat', 'Bird', 'Fish', 'Other']),
  breed: z.string().min(1, 'Breed is required').max(100, 'Breed too long'),
  age: z.number().int().min(0).max(300, 'Age must be between 0 and 300 months'),
  weight: z.number().positive().optional(),
  birthDate: z.string().datetime().optional(),
  photos: z.array(z.string().url()).optional(),
  preferences: z.record(z.any()).optional(),
  healthNotes: z.array(z.string()).optional(),
});

export const updatePetSchema = createPetSchema.partial();

// Soundscape validation schemas
export const createSoundscapeSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100, 'Name too long'),
  description: z.string().max(500, 'Description too long').optional(),
  category: z.enum(['relaxation', 'playtime', 'sleep', 'training', 'custom']),
  duration: z.number().int().min(30).max(3600, 'Duration must be between 30 and 3600 seconds'),
  tags: z.array(z.string()).optional(),
  isPublic: z.boolean().default(false),
});

export const updateSoundscapeSchema = createSoundscapeSchema.partial();

// Voting validation schemas
export const voteSchema = z.object({
  petId: z.string().min(1, 'Pet ID is required'),
  category: z.enum(['Most Photogenic', 'Most Adorable', 'Most Athletic', 'Most Smart']),
  reason: z.string().max(200, 'Reason too long').optional(),
});

export const submitPetSchema = z.object({
  petId: z.string().min(1, 'Pet ID is required'),
  category: z.enum(['Most Photogenic', 'Most Adorable', 'Most Athletic', 'Most Smart']),
  description: z.string().min(10, 'Description must be at least 10 characters').max(500, 'Description too long'),
  achievements: z.array(z.string()).optional(),
  tags: z.array(z.string()).optional(),
});

// User validation schemas
export const updateUserSchema = z.object({
  firstName: z.string().min(1, 'First name is required').max(50, 'First name too long').optional(),
  lastName: z.string().min(1, 'Last name is required').max(50, 'Last name too long').optional(),
  bio: z.string().max(500, 'Bio too long').optional(),
  interests: z.array(z.string()).optional(),
  preferences: z.record(z.any()).optional(),
});

// Pagination schemas
export const paginationSchema = z.object({
  page: z.number().int().min(1).default(1),
  limit: z.number().int().min(1).max(100).default(20),
  sortBy: z.string().optional(),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

// Search schemas
export const searchSchema = z.object({
  query: z.string().min(1, 'Search query is required').max(100, 'Query too long'),
  filters: z.record(z.any()).optional(),
});

// File upload schemas
export const fileUploadSchema = z.object({
  file: z.any().refine((file) => file && file.size > 0, 'File is required'),
  type: z.enum(['image', 'audio', 'document']),
  maxSize: z.number().default(10 * 1024 * 1024), // 10MB default
});