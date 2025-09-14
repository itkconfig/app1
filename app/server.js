// server.js (ฉบับปรับปรุง)

// --- Import Core & Third-party Libraries ---
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan'); // << เพิ่ม: สำหรับ Logging
const rateLimit = require('express-rate-limit'); // << เพิ่ม: สำหรับ Rate Limit
const swaggerUi = require('swagger-ui-express'); // << เพิ่ม: สำหรับ API Docs
const swaggerDocument = require('./swagger.json'); // << เพิ่ม: สมมติว่ามีไฟล์นี้อยู่

// --- App Configuration ---
const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';
const isDevelopment = NODE_ENV === 'development';

// --- Middlewares ---

// 1. Security (Helmet)
app.use(helmet());

// 2. CORS (จำกัดเฉพาะโดเมนที่เชื่อถือใน Production)
const corsOptions = {
    origin: isDevelopment ? '*' : ['https://your-frontend.com', 'https://another-domain.com']
};
app.use(cors(corsOptions));

// 3. JSON Body Parser
app.use(express.json());

// 4. HTTP Request Logger (Morgan)
app.use(morgan(isDevelopment ? 'dev' : 'combined'));

// 5. Rate Limiter (ป้องกันการยิง API รัวๆ)
const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 นาที
    max: 100, // จำกัด 100 requests ต่อ IP ใน 15 นาที
    message: { error: 'Too many requests from this IP, please try again after 15 minutes.' },
    standardHeaders: true,
    legacyHeaders: false,
});
app.use('/api/', apiLimiter); // << ใช้ Rate Limit กับ API เท่านั้น

// --- API Documentation (Swagger) ---
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// --- API Routes ---

// Root Endpoint (ปรับปรุงข้อความ)
app.get('/', (req, res) => {
    res.json({
        message: '🎉 Welcome to Custom App! Your journey begins here.',
        environment: NODE_ENV,
        version: '1.0.0',
        docs: `http://${req.hostname}:${PORT}/api-docs`
    });
});

// Health Check Endpoint (ครบถ้วนดีแล้ว)
app.get('/health', (req, res) => {
    res.status(200).json({
        status: '✅ UP',
        timestamp: new Date().toISOString(),
        uptime: `${process.uptime().toFixed(2)}s`,
    });
});

// API Endpoints (สมมติตัวอย่าง)
app.get('/api', (req, res) => {
    res.json({
        message: 'API is alive and kicking!',
        data: { users: 100, posts: 250, comments: 500 }
    });
});


// --- Error Handling ---

// 404 Not Found Handler
app.use((req, res, next) => {
    res.status(404).json({
        error: 'Resource not found. Check your path again.',
        path: req.originalUrl
    });
});

// Global Error Handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(err.status || 500).json({
        error: 'A server-side error occurred. 😞',
        message: isDevelopment ? err.message : 'Something went wrong!'
    });
});

// --- Server Initialization & Graceful Shutdown ---

const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server is blasting off on port ${PORT}`);
    console.log(`🌍 Environment: ${NODE_ENV}`);
    console.log(`🩺 Health check ready at http://localhost:${PORT}/health`);
    console.log(`📚 API Docs available at http://localhost:${PORT}/api-docs`);
});

const gracefulShutdown = (signal) => {
    console.log(`\nได้รับสัญญาณ ${signal}. กำลังเริ่มกระบวนการ Graceful Shutdown...`);
    server.close(() => {
        console.log('✅ HTTP server closed. Application terminated.');
        process.exit(0);
    });

    // หากเซิร์ฟเวอร์ไม่ปิดใน 10 วินาที, บังคับปิด
    setTimeout(() => {
        console.error('❌ Could not close connections in time, forcing shutdown.');
        process.exit(1);
    }, 10000);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
