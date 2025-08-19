import express from 'express';
import { asyncHandler } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { getFirestore } from '../services/firebase';
import { ValidationError } from '../middleware/errorHandler';
import { z } from 'zod';

const router = express.Router();

// Gamification schemas
const achievementUnlockSchema = z.object({
  achievementId: z.string(),
  userId: z.string(),
  unlockData: z.record(z.any()).optional(),
});

const challengeCompletionSchema = z.object({
  challengeId: z.string(),
  userId: z.string(),
  completionData: z.record(z.any()).optional(),
});

const rewardPurchaseSchema = z.object({
  rewardId: z.string(),
  userId: z.string(),
  purchaseData: z.record(z.any()).optional(),
});

/**
 * @route GET /api/gamification/achievements
 * @desc Get all available achievements
 * @access Protected
 */
router.get('/achievements', asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const achievementsRef = db.collection('achievements');
    const snapshot = await achievementsRef.get();
    
    const achievements = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({
      success: true,
      achievements,
      count: achievements.length,
    });
  } catch (error) {
    logger.error('Get achievements error:', error);
    throw error;
  }
}));

/**
 * @route GET /api/gamification/achievements/user/:userId
 * @desc Get user's achievements
 * @access Protected
 */
router.get('/achievements/user/:userId', asyncHandler(async (req, res) => {
  try {
    const { userId } = req.params;
    const db = getFirestore();
    
    const userAchievementsRef = db.collection('users').doc(userId).collection('achievements');
    const snapshot = await userAchievementsRef.get();
    
    const achievements = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      unlockedAt: doc.data().unlockedAt?.toDate(),
    }));

    res.json({
      success: true,
      achievements,
      count: achievements.length,
    });
  } catch (error) {
    logger.error('Get user achievements error:', error);
    throw error;
  }
}));

/**
 * @route POST /api/gamification/achievements/unlock
 * @desc Unlock an achievement for a user
 * @access Protected
 */
router.post('/achievements/unlock', asyncHandler(async (req, res) => {
  try {
    const { achievementId, userId, unlockData } = achievementUnlockSchema.parse(req.body);
    const db = getFirestore();
    
    // Check if achievement exists
    const achievementRef = db.collection('achievements').doc(achievementId);
    const achievementDoc = await achievementRef.get();
    
    if (!achievementDoc.exists) {
      throw new ValidationError('Achievement not found');
    }
    
    const achievement = achievementDoc.data()!;
    
    // Check if user already has this achievement
    const userAchievementRef = db.collection('users').doc(userId).collection('achievements').doc(achievementId);
    const userAchievementDoc = await userAchievementRef.get();
    
    if (userAchievementDoc.exists) {
      throw new ValidationError('Achievement already unlocked');
    }
    
    // Unlock achievement
    await userAchievementRef.set({
      ...achievement,
      unlockedAt: new Date(),
      unlockData: unlockData || {},
    });
    
    // Add experience points
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      experience: admin.firestore.FieldValue.increment(achievement.experienceReward || 0),
      totalAchievements: admin.firestore.FieldValue.increment(1),
    });
    
    logger.info(`Achievement unlocked: ${achievementId} for user: ${userId}`);
    
    res.json({
      success: true,
      achievement: {
        id: achievementId,
        ...achievement,
        unlockedAt: new Date(),
      },
      experienceGained: achievement.experienceReward || 0,
    });
  } catch (error) {
    logger.error('Unlock achievement error:', error);
    throw error;
  }
}));

/**
 * @route GET /api/gamification/rewards
 * @desc Get all available rewards
 * @access Protected
 */
router.get('/rewards', asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const rewardsRef = db.collection('rewards');
    const snapshot = await rewardsRef.get();
    
    const rewards = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({
      success: true,
      rewards,
      count: rewards.length,
    });
  } catch (error) {
    logger.error('Get rewards error:', error);
    throw error;
  }
}));

/**
 * @route GET /api/gamification/rewards/user/:userId
 * @desc Get user's unlocked rewards
 * @access Protected
 */
router.get('/rewards/user/:userId', asyncHandler(async (req, res) => {
  try {
    const { userId } = req.params;
    const db = getFirestore();
    
    const userRewardsRef = db.collection('users').doc(userId).collection('rewards');
    const snapshot = await userRewardsRef.get();
    
    const rewards = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      unlockedAt: doc.data().unlockedAt?.toDate(),
    }));

    res.json({
      success: true,
      rewards,
      count: rewards.length,
    });
  } catch (error) {
    logger.error('Get user rewards error:', error);
    throw error;
  }
}));

/**
 * @route POST /api/gamification/rewards/purchase
 * @desc Purchase a reward
 * @access Protected
 */
router.post('/rewards/purchase', asyncHandler(async (req, res) => {
  try {
    const { rewardId, userId, purchaseData } = rewardPurchaseSchema.parse(req.body);
    const db = getFirestore();
    
    // Check if reward exists
    const rewardRef = db.collection('rewards').doc(rewardId);
    const rewardDoc = await rewardRef.get();
    
    if (!rewardDoc.exists) {
      throw new ValidationError('Reward not found');
    }
    
    const reward = rewardDoc.data()!;
    
    // Check if user has enough points
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      throw new ValidationError('User not found');
    }
    
    const user = userDoc.data()!;
    const userPoints = user.points || 0;
    
    if (userPoints < (reward.pointCost || 0)) {
      throw new ValidationError('Insufficient points');
    }
    
    // Purchase reward
    const userRewardRef = db.collection('users').doc(userId).collection('rewards').doc(rewardId);
    await userRewardRef.set({
      ...reward,
      purchasedAt: new Date(),
      purchaseData: purchaseData || {},
    });
    
    // Deduct points
    await userRef.update({
      points: admin.firestore.FieldValue.increment(-(reward.pointCost || 0)),
      totalRewards: admin.firestore.FieldValue.increment(1),
    });
    
    logger.info(`Reward purchased: ${rewardId} by user: ${userId}`);
    
    res.json({
      success: true,
      reward: {
        id: rewardId,
        ...reward,
        purchasedAt: new Date(),
      },
      pointsSpent: reward.pointCost || 0,
      remainingPoints: userPoints - (reward.pointCost || 0),
    });
  } catch (error) {
    logger.error('Purchase reward error:', error);
    throw error;
  }
}));

/**
 * @route GET /api/gamification/challenges
 * @desc Get available challenges
 * @access Protected
 */
router.get('/challenges', asyncHandler(async (req, res) => {
  try {
    const { type, category } = req.query;
    const db = getFirestore();
    
    let challengesRef = db.collection('challenges');
    
    if (type) {
      challengesRef = challengesRef.where('type', '==', type);
    }
    
    if (category) {
      challengesRef = challengesRef.where('category', '==', category);
    }
    
    const snapshot = await challengesRef.get();
    
    const challenges = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      expiresAt: doc.data().expiresAt?.toDate(),
    }));

    res.json({
      success: true,
      challenges,
      count: challenges.length,
    });
  } catch (error) {
    logger.error('Get challenges error:', error);
    throw error;
  }
}));

/**
 * @route POST /api/gamification/challenges/complete
 * @desc Complete a challenge
 * @access Protected
 */
router.post('/challenges/complete', asyncHandler(async (req, res) => {
  try {
    const { challengeId, userId, completionData } = challengeCompletionSchema.parse(req.body);
    const db = getFirestore();
    
    // Check if challenge exists
    const challengeRef = db.collection('challenges').doc(challengeId);
    const challengeDoc = await challengeRef.get();
    
    if (!challengeDoc.exists) {
      throw new ValidationError('Challenge not found');
    }
    
    const challenge = challengeDoc.data()!;
    
    // Check if challenge is expired
    if (challenge.expiresAt && challenge.expiresAt.toDate() < new Date()) {
      throw new ValidationError('Challenge has expired');
    }
    
    // Check if user already completed this challenge
    const userChallengeRef = db.collection('users').doc(userId).collection('challenges').doc(challengeId);
    const userChallengeDoc = await userChallengeRef.get();
    
    if (userChallengeDoc.exists) {
      throw new ValidationError('Challenge already completed');
    }
    
    // Complete challenge
    await userChallengeRef.set({
      ...challenge,
      completedAt: new Date(),
      completionData: completionData || {},
    });
    
    // Add experience points
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      experience: admin.firestore.FieldValue.increment(challenge.experienceReward || 0),
      points: admin.firestore.FieldValue.increment(challenge.pointReward || 0),
      totalChallenges: admin.firestore.FieldValue.increment(1),
    });
    
    logger.info(`Challenge completed: ${challengeId} by user: ${userId}`);
    
    res.json({
      success: true,
      challenge: {
        id: challengeId,
        ...challenge,
        completedAt: new Date(),
      },
      experienceGained: challenge.experienceReward || 0,
      pointsGained: challenge.pointReward || 0,
    });
  } catch (error) {
    logger.error('Complete challenge error:', error);
    throw error;
  }
}));

/**
 * @route GET /api/gamification/leaderboard
 * @desc Get leaderboard
 * @access Protected
 */
router.get('/leaderboard', asyncHandler(async (req, res) => {
  try {
    const { category, limit = 50, page = 1 } = req.query;
    const db = getFirestore();
    
    let usersRef = db.collection('users');
    
    if (category === 'experience') {
      usersRef = usersRef.orderBy('experience', 'desc');
    } else if (category === 'achievements') {
      usersRef = usersRef.orderBy('totalAchievements', 'desc');
    } else if (category === 'streak') {
      usersRef = usersRef.orderBy('currentStreak', 'desc');
    } else {
      usersRef = usersRef.orderBy('level', 'desc').orderBy('experience', 'desc');
    }
    
    const snapshot = await usersRef.limit(parseInt(limit as string)).get();
    
    const leaderboard = snapshot.docs.map((doc, index) => ({
      rank: (parseInt(page as string) - 1) * parseInt(limit as string) + index + 1,
      userId: doc.id,
      username: doc.data().profile?.firstName + ' ' + doc.data().profile?.lastName,
      avatarUrl: doc.data().profile?.avatarUrl,
      level: doc.data().level || 1,
      experience: doc.data().experience || 0,
      totalAchievements: doc.data().totalAchievements || 0,
      currentStreak: doc.data().currentStreak || 0,
      lastActivity: doc.data().lastActivity?.toDate(),
    }));

    res.json({
      success: true,
      leaderboard,
      count: leaderboard.length,
      category: category || 'overall',
    });
  } catch (error) {
    logger.error('Get leaderboard error:', error);
    throw error;
  }
}));

/**
 * @route GET /api/gamification/user/:userId/progress
 * @desc Get user's gamification progress
 * @access Protected
 */
router.get('/user/:userId/progress', asyncHandler(async (req, res) => {
  try {
    const { userId } = req.params;
    const db = getFirestore();
    
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      throw new ValidationError('User not found');
    }
    
    const user = userDoc.data()!;
    
    // Calculate level and progress
    const level = user.level || 1;
    const experience = user.experience || 0;
    const experienceToNextLevel = 100 + (level - 1) * 50;
    const levelProgress = experience / experienceToNextLevel;
    
    // Get level title
    const levelTitle = getLevelTitle(level);
    
    res.json({
      success: true,
      progress: {
        level,
        experience,
        experienceToNextLevel,
        levelProgress,
        levelTitle,
        totalPoints: user.points || 0,
        achievementsUnlocked: user.totalAchievements || 0,
        totalAchievements: 0, // Would need to count total available achievements
        streaks: user.streaks || {},
        currentStreak: user.currentStreak || 0,
        longestStreak: user.longestStreak || 0,
        lastActivity: user.lastActivity?.toDate(),
      },
    });
  } catch (error) {
    logger.error('Get user progress error:', error);
    throw error;
  }
}));

/**
 * @route POST /api/gamification/user/:userId/experience
 * @desc Add experience points to user
 * @access Protected
 */
router.post('/user/:userId/experience', asyncHandler(async (req, res) => {
  try {
    const { userId } = req.params;
    const { points, reason, category } = req.body;
    const db = getFirestore();
    
    if (!points || points <= 0) {
      throw new ValidationError('Invalid points value');
    }
    
    const userRef = db.collection('users').doc(userId);
    
    // Add experience points
    await userRef.update({
      experience: admin.firestore.FieldValue.increment(points),
      lastActivity: new Date(),
    });
    
    // Log experience gain
    await db.collection('users').doc(userId).collection('experienceLog').add({
      points,
      reason: reason || 'Activity',
      category: category || 'general',
      timestamp: new Date(),
    });
    
    logger.info(`Experience added: ${points} points to user: ${userId}, reason: ${reason}`);
    
    res.json({
      success: true,
      pointsAdded: points,
      reason,
      category,
    });
  } catch (error) {
    logger.error('Add experience error:', error);
    throw error;
  }
}));

// Helper functions
function getLevelTitle(level: number): string {
  if (level >= 50) return 'Legendary Pet Guardian';
  if (level >= 40) return 'Master Pet Caretaker';
  if (level >= 30) return 'Expert Pet Parent';
  if (level >= 20) return 'Advanced Pet Owner';
  if (level >= 10) return 'Experienced Pet Lover';
  if (level >= 5) return 'Dedicated Pet Parent';
  if (level >= 2) return 'Pet Enthusiast';
  return 'New Pet Parent';
}

export default router;