// This file creates a simple proxy server for development
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const app = express();

// Enable CORS for all routes
app.use(cors());

// Proxy API requests to backend
app.use('/api', createProxyMiddleware({
  target: 'http://127.0.0.1:8000',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '/api',
  },
}));

// Serve static files
app.use(express.static('./build/web'));

// Start server
const PORT = 8080;
app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
  console.log(`Proxying API requests to http://127.0.0.1:8000`);
}); 