const express = require("express");
const pool = require("../db");
const router = express.Router();

function parseDateOrNull(v) {
  if (!v) return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

// POST /workout_sessions  -> create session
router.post("/", async (req, res) => {
  try {
    const {
      user_id,
      custom_workouts_id = null,
      started_at = null,
    } = req.body || {};
    if (!user_id) {
      return res.status(400).json({ message: "user_id is required" });
    }

    const q = `
      INSERT INTO workout_sessions
        (user_id, custom_workouts_id, started_at)
      VALUES ($1, $2, COALESCE($3::timestamp, NOW()))
      RETURNING *;
    `;
    const { rows } = await pool.query(q, [user_id, custom_workouts_id, started_at]);
    return res.status(201).json(rows[0]);
  } catch (err) {
    console.error("[POST /workout_sessions] Error:", err);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

// POST /workout_sessions/:sessionId/exercises/bulk
router.post("/:sessionId/exercises/bulk", async (req, res) => {
  const client = await pool.connect();
  try {
    const sessionId = parseInt(req.params.sessionId, 10);
    const { items } = req.body || {};
    if (!sessionId || !Array.isArray(items)) {
      return res.status(400).json({ message: "sessionId and items[] are required" });
    }

    await client.query("BEGIN");
    const ins = `
      INSERT INTO workout_session_exercises
        (workout_session_id, exercise_id, order_in_routine, sets_done, reps_done, duration_done)
      VALUES ($1,$2,$3,$4,$5,$6)
      RETURNING *;
    `;

    const inserted = [];
    for (const it of items) {
      const params = [
        sessionId,
        it.exercise_id,
        it.order_in_routine ?? null,
        it.sets_done ?? null,
        it.reps_done ?? null,
        it.duration_done ?? null,
      ];
      const { rows } = await client.query(ins, params);
      inserted.push(rows[0]);
    }
    await client.query("COMMIT");
    return res.status(201).json(inserted);
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("[POST /workout_sessions/:sessionId/exercises/bulk] Error:", err);
    return res.status(500).json({ message: "Internal Server Error" });
  } finally {
    client.release();
  }
});

// PATCH /workout_sessions/:sessionId/complete  -> finalize session (no note)
router.patch("/:sessionId/complete", async (req, res) => {
  const client = await pool.connect();
  try {
    const sessionId = parseInt(req.params.sessionId, 10);
    if (!sessionId) return res.status(400).json({ message: "sessionId is required" });

    const completedAt = parseDateOrNull(req.body?.completed_at) ?? new Date();

    await client.query("BEGIN");

    const sumQ = `
      SELECT
        COALESCE(SUM(sets_done), 0)      AS sum_sets,
        COALESCE(SUM(reps_done), 0)      AS sum_reps,
        COALESCE(SUM(duration_done), 0)  AS sum_duration
      FROM workout_session_exercises
      WHERE workout_session_id = $1;
    `;
    const sums = (await client.query(sumQ, [sessionId])).rows[0];

    const upd = `
      UPDATE workout_sessions
      SET completed_at = $2::timestamp,
          total_sets   = $3,
          total_reps   = $4,
          total_duration = $5
      WHERE workout_session_id = $1
      RETURNING *;
    `;
    const { rows } = await client.query(upd, [
      sessionId,
      completedAt, // แคสต์ใน SQL เป็น ::timestamp
      sums.sum_sets,
      sums.sum_reps,
      sums.sum_duration,
    ]);

    await client.query("COMMIT");
    return res.json(rows[0]);
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("[PATCH /workout_sessions/:sessionId/complete] Error:", err);
    return res.status(500).json({ message: "Internal Server Error" });
  } finally {
    client.release();
  }
});

// GET /workout_sessions/:userId?from=&to=&limit=&offset=
router.get("/:userId", async (req, res) => {
  try {
    const userId = parseInt(req.params.userId, 10);
    if (!userId) return res.status(400).json({ message: "userId ไม่ถูกต้อง" });

    const limit  = Math.min(parseInt(req.query.limit ?? "100", 10), 300);
    theOffset    = parseInt(req.query.offset ?? "0", 10);
    const toParam   = parseDateOrNull(req.query.to) ?? new Date();
    const fromParam = parseDateOrNull(req.query.from) ?? new Date(toParam.getTime() - 30*24*60*60*1000);

    const q = `
      SELECT
        s.workout_session_id,
        s.user_id,
        s.custom_workouts_id,
        cw.name AS custom_workout_name,
        s.started_at,
        s.completed_at,
        s.total_sets,
        s.total_reps,
        s.total_duration,
        COALESCE(
          json_agg(
            json_build_object(
              'workout_session_exercise_id', wse.workout_session_exercise_id,
              'exercise_id', wse.exercise_id,
              'order_in_routine', wse.order_in_routine,
              'sets_done', wse.sets_done,
              'reps_done', wse.reps_done,
              'duration_done', wse.duration_done,
              'name', e.name_en,
              'image_url', e.image_url
            )
            ORDER BY wse.order_in_routine NULLS LAST
          ) FILTER (WHERE wse.workout_session_exercise_id IS NOT NULL),
          '[]'::json
        ) AS exercises
      FROM workout_sessions s
      LEFT JOIN custom_workouts cw ON cw.custom_workouts_id = s.custom_workouts_id
      LEFT JOIN workout_session_exercises wse ON wse.workout_session_id = s.workout_session_id
      LEFT JOIN exercises e ON e.exercise_id = wse.exercise_id
      WHERE s.user_id = $1
        AND s.started_at >= $2::timestamp
        AND s.started_at <  $3::timestamp
      GROUP BY s.workout_session_id, cw.name
      ORDER BY s.started_at DESC
      LIMIT $4 OFFSET $5;
    `;
    const params = [userId, fromParam, toParam, limit, theOffset];
    const { rows } = await pool.query(q, params);
    return res.json(rows);
  } catch (err) {
    console.error("[GET /workout_sessions/:userId] Error:", err);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

module.exports = router;
