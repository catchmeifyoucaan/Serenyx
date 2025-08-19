import { Request, Response, NextFunction } from 'express';
import { logAudit } from '../utils/logger';

export const auditLogger = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const startTime = Date.now();
  const originalSend = res.send;

  // Override res.send to capture response data
  res.send = function(data: any) {
    const duration = Date.now() - startTime;
    
    // Log the request/response
    logAudit(
      req.user?.uid || 'anonymous',
      `${req.method} ${req.path}`,
      'api_request',
      {
        method: req.method,
        path: req.path,
        statusCode: res.statusCode,
        duration: `${duration}ms`,
        userAgent: req.get('User-Agent'),
        ip: req.ip,
        requestBody: req.method !== 'GET' ? req.body : undefined,
        responseSize: typeof data === 'string' ? data.length : JSON.stringify(data).length,
        timestamp: new Date().toISOString(),
      }
    );

    // Call the original send method
    return originalSend.call(this, data);
  };

  next();
};

// Specific audit logger for sensitive operations
export const sensitiveAuditLogger = (
  operation: string,
  resource: string
) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const startTime = Date.now();
    const originalSend = res.send;

    res.send = function(data: any) {
      const duration = Date.now() - startTime;
      
      logAudit(
        req.user?.uid || 'anonymous',
        operation,
        resource,
        {
          method: req.method,
          path: req.path,
          statusCode: res.statusCode,
          duration: `${duration}ms`,
          userAgent: req.get('User-Agent'),
          ip: req.ip,
          requestBody: req.body,
          responseSize: typeof data === 'string' ? data.length : JSON.stringify(data).length,
          timestamp: new Date().toISOString(),
          sensitive: true,
        }
      );

      return originalSend.call(this, data);
    };

    next();
  };
};