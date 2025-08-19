import { Request, Response, NextFunction } from 'express';
import { verifyIdToken } from '../services/firebase';
import { logSecurity } from '../utils/logger';

// Extend Express Request interface to include user
declare global {
  namespace Express {
    interface Request {
      user?: {
        uid: string;
        email: string;
        emailVerified: boolean;
        [key: string]: any;
      };
    }
  }
}

export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      logSecurity('MISSING_AUTH_HEADER', undefined, { ip: req.ip, path: req.path });
      res.status(401).json({
        error: 'Unauthorized',
        message: 'No authorization header provided',
      });
      return;
    }

    const token = authHeader.replace('Bearer ', '');
    
    if (!token) {
      logSecurity('INVALID_AUTH_HEADER', undefined, { ip: req.ip, path: req.path });
      res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid authorization header format',
      });
      return;
    }

    try {
      const decodedToken = await verifyIdToken(token);
      
      // Add user info to request
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email || '',
        emailVerified: decodedToken.email_verified || false,
        ...decodedToken,
      };

      next();
    } catch (error) {
      logSecurity('INVALID_TOKEN', undefined, { 
        ip: req.ip, 
        path: req.path, 
        error: error instanceof Error ? error.message : 'Unknown error' 
      });
      
      res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid or expired token',
      });
    }
  } catch (error) {
    logSecurity('AUTH_MIDDLEWARE_ERROR', undefined, { 
      ip: req.ip, 
      path: req.path, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
    
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Authentication service error',
    });
  }
};

// Optional auth middleware - doesn't fail if no token provided
export const optionalAuthMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      next();
      return;
    }

    const token = authHeader.replace('Bearer ', '');
    
    if (!token) {
      next();
      return;
    }

    try {
      const decodedToken = await verifyIdToken(token);
      
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email || '',
        emailVerified: decodedToken.email_verified || false,
        ...decodedToken,
      };

      next();
    } catch (error) {
      // Continue without authentication
      next();
    }
  } catch (error) {
    // Continue without authentication
    next();
  }
};

// Admin-only middleware
export const adminMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  if (!req.user) {
    res.status(401).json({
      error: 'Unauthorized',
      message: 'Authentication required',
    });
    return;
  }

  // Check if user has admin role
  const isAdmin = req.user.admin === true || req.user.role === 'admin';
  
  if (!isAdmin) {
    logSecurity('ADMIN_ACCESS_DENIED', req.user.uid, { 
      ip: req.ip, 
      path: req.path 
    });
    
    res.status(403).json({
      error: 'Forbidden',
      message: 'Admin access required',
    });
    return;
  }

  next();
};

// Premium user middleware
export const premiumMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  if (!req.user) {
    res.status(401).json({
      error: 'Unauthorized',
      message: 'Authentication required',
    });
    return;
  }

  // Check if user has premium subscription
  const isPremium = req.user.premium === true || req.user.subscription === 'premium';
  
  if (!isPremium) {
    logSecurity('PREMIUM_ACCESS_DENIED', req.user.uid, { 
      ip: req.ip, 
      path: req.path 
    });
    
    res.status(403).json({
      error: 'Forbidden',
      message: 'Premium subscription required',
    });
    return;
  }

  next();
};