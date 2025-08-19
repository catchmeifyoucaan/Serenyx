import { Router } from 'express';
import { z } from 'zod';
import fetch from 'node-fetch';
export const soundscapeRouter = Router();
const generateSchema = z.object({
    prompt: z.string().min(3),
    voiceId: z.string().optional(),
});
soundscapeRouter.post('/generate', async (req, res) => {
    try {
        const body = generateSchema.parse(req.body);
        const key = process.env.ELEVENLABS_API_KEY;
        if (!key)
            return res.status(500).json({ error: 'Missing ElevenLabs key' });
        const voiceId = body.voiceId || 'EXAVITQu4vr4xnSDxMaL';
        const url = `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`;
        const r = await fetch(url, {
            method: 'POST',
            headers: {
                'xi-api-key': key,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                text: body.prompt,
                model_id: 'eleven_multilingual_v2',
                voice_settings: { stability: 0.5, similarity_boost: 0.75 },
            }),
        });
        if (!r.ok)
            return res.status(502).json({ error: 'ElevenLabs error' });
        const arrayBuffer = await r.arrayBuffer();
        const base64 = Buffer.from(arrayBuffer).toString('base64');
        // For MVP, return base64 data URL; in prod, upload to Storage and return URL
        return res.json({ audioUrl: `data:audio/mpeg;base64,${base64}` });
    }
    catch (e) {
        return res.status(500).json({ error: 'Generation failed' });
    }
});
