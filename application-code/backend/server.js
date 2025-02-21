require("dotenv").config();
const express = require("express");
const cors = require("cors");

const app = express();
const port = process.env.PORT || 3000;

// Enable CORS for frontend access
app.use(cors());

// API route to fetch message
app.get("/api/hello-world", async (req, res) => {
  try {
    // http reques to the cache service from env variables CACHE_SERVICE_NAME and CACHE_SERVICE_PORT
    const response = await fetch(
      `http://${process.env.CACHE_SERVICE_NAME}:${process.env.CACHE_SERVICE_PORT}`
    );
    const data = await response.json();

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Database query failed" });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
