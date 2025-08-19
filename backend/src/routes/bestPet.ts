import { Router } from 'express';
import { z } from 'zod';
import { getFirestore } from 'firebase-admin/firestore';

export const bestPetRouter = Router();

const voteSchema = z.object({
  petId: z.string().min(1),
});

bestPetRouter.get('/leaderboard', async (req, res) => {
  try {
    const db = getFirestore();
    const snap = await db.collection('best_pet_votes').orderBy('votes', 'desc').limit(100).get();
    const entries = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    return res.json({ entries });
  } catch (e) {
    return res.status(500).json({ error: 'Failed to load leaderboard' });
  }
});

bestPetRouter.post('/vote', async (req, res) => {
  try {
    const body = voteSchema.parse(req.body);
    const uid = (req as any).user.uid as string;
    const db = getFirestore();

    // Rate limit per user per pet per day via Firestore
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const voteKey = `${uid}_${body.petId}_${today.toISOString().slice(0, 10)}`;
    const voteRef = db.collection('best_pet_daily_votes').doc(voteKey);
    const voteDoc = await voteRef.get();
    if (voteDoc.exists) return res.status(429).json({ error: 'Already voted today' });

    await voteRef.set({ uid, petId: body.petId, date: today.toISOString() });

    const petRef = db.collection('best_pet_votes').doc(body.petId);
    await db.runTransaction(async (tx) => {
      const current = await tx.get(petRef);
      const data = current.exists ? current.data()! : { votes: 0 };
      tx.set(petRef, { ...data, petId: body.petId, votes: (data.votes || 0) + 1 }, { merge: true });
    });

    return res.status(201).json({ ok: true });
  } catch (e: any) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Invalid body' });
    return res.status(500).json({ error: 'Vote failed' });
  }
});

