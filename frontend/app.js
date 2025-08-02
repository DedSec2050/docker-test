const express = require("express");
const path = require("path");
const bodyParser = require("body-parser");
const axios = require("axios");

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));
app.use(express.static(path.join(__dirname, "public")));

// Backend URL - use environment variable or default to localhost for local development
const BACKEND_URL = process.env.BACKEND_URL || "http://127.0.0.1:8000/";

// Home page with form
app.get("/", async (req, res) => {
  try {
    console.log(`Fetching todos from: ${BACKEND_URL}/api`);
    const response = await axios.get(`${BACKEND_URL}/api`);
    const todos = response.data.todos || [];
    console.log(`Fetched ${todos.length} todos`);
    res.render("form", { todos, error: null });
  } catch (err) {
    console.error("Error fetching todos:", err.message);
    res.render("form", {
      todos: [],
      error: "Failed to fetch todos. Backend might be unavailable.",
    });
  }
});

// Form POST handler - submits to Flask backend
app.post("/submit", async (req, res) => {
  try {
    console.log("Submitting todo:", req.body);
    console.log(`Posting to: ${BACKEND_URL}/submittodoitem`);

    const response = await axios.post(
      `${BACKEND_URL}/submittodoitem`,
      new URLSearchParams(req.body),
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    console.log("Backend response:", response.data);
    res.redirect("/");
  } catch (error) {
    console.error("Error submitting todo:", error.message);
    if (error.response) {
      console.error("Backend error:", error.response.data);
    }
    res.send(
      "Failed to submit. Please try again. Backend might be unavailable."
    );
  }
});

// Health check endpoint
app.get("/health", async (req, res) => {
  try {
    const response = await axios.get(`${BACKEND_URL}/health`);
    res.render("health", {
      frontend: "healthy",
      backend: response.data,
    });
  } catch (error) {
    res.render("health", {
      frontend: "healthy",
      backend: "unavailable",
      error: error.message,
    });
  }
});

// API endpoint for AJAX health check
app.get("/api/health", async (req, res) => {
  try {
    const response = await axios.get(`${BACKEND_URL}/health`);
    res.json({
      frontend: "healthy",
      backend: response.data,
    });
  } catch (error) {
    res.status(503).json({
      frontend: "healthy",
      backend: "unavailable",
      error: error.message,
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Frontend running on port ${PORT}`);
  console.log(`Backend URL configured as: ${BACKEND_URL}`);
  console.log(`🌐 Access the app at: http://localhost:${PORT}`);
});
