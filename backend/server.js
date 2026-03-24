const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/auth");
const exerciseRoutes = require("./routes/exercises");
const userExerciseRoutes = require("./routes/userExercises");
const customWorkoutRoutes = require("./routes/customWorkouts");
const workoutSessionsRouter = require("./routes/workoutSessions");
const exerciseHistoryRouter = require("./routes/exerciseHistory");
const requestsRouter = require("./routes/requests");
const musclesRoutes = require("./routes/muscles");

const app = express();
app.use(cors());
app.use(express.json());

// ROUTES
app.use("/", authRoutes);
app.use("/", exerciseRoutes);
app.use("/", userExerciseRoutes);
app.use("/", customWorkoutRoutes);
app.use("/workout_sessions", workoutSessionsRouter);
app.use("/exercise_history", exerciseHistoryRouter);
app.use("/requests", requestsRouter);
app.use("/muscles", musclesRoutes);

//  Health check
app.get("/", (req, res) => {
  res.send(" SkeletonFit API is running...");
});

// START SERVER
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`SkeletonFit API is running on http://localhost:${PORT}`);
});
