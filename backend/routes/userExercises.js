const express = require("express");
const pool = require("../db");
const router = express.Router();

// CREATE / UPDATE
router.post("/user_exercises", async (req, res) => {
  const { user_id, exercise_id, sets, reps, duration } = req.body;
  if (!user_id || !exercise_id)
    return res.status(400).json({ error: "Missing user_id or exercise_id" });

  try {
    const query = `
      INSERT INTO user_exercises (user_id, exercise_id, sets, reps, duration)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (user_id, exercise_id)
      DO UPDATE SET
        sets = EXCLUDED.sets,
        reps = EXCLUDED.reps,
        duration = EXCLUDED.duration,
        updated_at = NOW()
      RETURNING *;
    `;
    const { rows } = await pool.query(query, [user_id, exercise_id, sets, reps, duration]);
    res.status(200).json({ message: "User exercise saved successfully", data: rows[0] });
  } catch (err) {
    console.error("Error saving user exercise:", err);
    res.status(500).json({ error: "Failed to save user exercise", detail: err.message });
  }
});

// GET SINGLE
router.get("/user_exercises/:user_id/:exercise_id", async (req, res) => {
  const { user_id, exercise_id } = req.params;
  try {
    const { rows } = await pool.query(
      "SELECT sets, reps, duration FROM user_exercises WHERE user_id=$1 AND exercise_id=$2",
      [user_id, exercise_id]
    );
    res.json(rows[0] || {});
  } catch (err) {
    console.error("Error fetching user exercise:", err);
    res.status(500).json({ error: "Failed to fetch user exercise", detail: err.message });
  }
});

// GET ALL
router.get("/user_exercises/:user_id", async (req, res) => {
  const { user_id } = req.params;
  try {
    const { rows } = await pool.query(
      "SELECT * FROM user_exercises WHERE user_id=$1 ORDER BY updated_at DESC",
      [user_id]
    );
    res.json(rows);
  } catch (err) {
    console.error("Error fetching user exercises:", err);
    res.status(500).json({ error: "Failed to fetch user exercises", detail: err.message });
  }
});

// DELETE
router.delete("/user_exercises/:user_id/:exercise_id", async (req, res) => {
  const { user_id, exercise_id } = req.params;
  try {
    const result = await pool.query(
      "DELETE FROM user_exercises WHERE user_id=$1 AND exercise_id=$2 RETURNING *",
      [user_id, exercise_id]
    );
    if (result.rows.length > 0) {
      res.status(200).json({ message: "User exercise deleted successfully" });
    } else {
      res.status(404).json({ error: "User exercise not found" });
    }
  } catch (err) {
    console.error("Error deleting user exercise:", err);
    res.status(500).json({ error: "Failed to delete user exercise", detail: err.message });
  }
});

module.exports = router;
