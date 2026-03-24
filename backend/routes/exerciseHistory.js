const express = require("express");
const pool = require("../db");
const router = express.Router();

// ---------- Helpers ----------
function parseDateOrNull(v) {
  if (!v) return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

// POST /exercise_history
// body: { user_id, exercise_id, sets_done?, reps_done?, duration_done?, completed_at?, custom_workouts_id? }
router.post("/", async (req, res) => {
  try {
    const {
      user_id,
      exercise_id,
      sets_done = null,
      reps_done = null,
      duration_done = null,
      completed_at = null,
      custom_workouts_id = null,
    } = req.body || {};

    if (!user_id || !exercise_id) {
      return res
        .status(400)
        .json({ message: "user_id และ exercise_id จำเป็นต้องมี" });
    }

    const q = `
      INSERT INTO exercise_history
        (user_id, exercise_id, sets_done, reps_done, duration_done, completed_at, custom_workouts_id)
      VALUES ($1, $2, $3, $4, $5, COALESCE($6::timestamp, NOW()), $7)
      RETURNING *;
    `;
    const params = [
      user_id,
      exercise_id,
      sets_done,
      reps_done,
      duration_done,
      completed_at,           // ให้ PG แคสต์เป็น ::timestamp เอง
      custom_workouts_id,
    ];

    const { rows } = await pool.query(q, params);
    return res.status(201).json(rows[0]);
  } catch (err) {
    console.error("[POST /exercise_history] Error:", err);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

// GET /exercise_history/:userId?from=&to=&limit=&offset=
router.get("/:userId", async (req, res) => {
  try {
    const userId = parseInt(req.params.userId, 10);
    if (!userId) return res.status(400).json({ message: "userId ไม่ถูกต้อง" });

    const limit = Math.min(parseInt(req.query.limit ?? "200", 10), 500);
    const offset = parseInt(req.query.offset ?? "0", 10);

    const toParam = parseDateOrNull(req.query.to) ?? new Date();
    const fromParam =
      parseDateOrNull(req.query.from) ??
      new Date(toParam.getTime() - 30 * 24 * 60 * 60 * 1000);

    const q = `
      SELECT
        eh.exercise_history_id,
        eh.user_id,
        eh.exercise_id,
        e.name_en AS name_en,
        e.name_en AS name,
        e.image_url,
        eh.sets_done,
        eh.reps_done,
        eh.duration_done,
        eh.completed_at,
        eh.custom_workouts_id
      FROM exercise_history eh
      JOIN exercises e ON e.exercise_id = eh.exercise_id
      WHERE eh.user_id = $1
        AND eh.completed_at >= $2::timestamp
        AND eh.completed_at <  $3::timestamp
      ORDER BY eh.completed_at DESC
      LIMIT $4 OFFSET $5;
    `;
    const params = [userId, fromParam, toParam, limit, offset];

    const { rows } = await pool.query(q, params);
    return res.json(rows);
  } catch (err) {
    console.error("[GET /exercise_history/:userId] Error:", err);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

// DELETE /exercise_history/:historyId
router.delete("/:historyId", async (req, res) => {
  try {
    const historyId = parseInt(req.params.historyId, 10);
    if (!historyId)
      return res.status(400).json({ message: "historyId ไม่ถูกต้อง" });

    await pool.query(
      "DELETE FROM exercise_history WHERE exercise_history_id = $1;",
      [historyId]
    );
    return res.json({ message: "deleted" });
  } catch (err) {
    console.error("[DELETE /exercise_history/:historyId] Error:", err);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

module.exports = router;
