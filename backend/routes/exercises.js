const express = require("express");
const pool = require("../db");
const router = express.Router();

router.get("/exercises", async (_req, res) => {
  try {
    const sql = `
      SELECT
        e.exercise_id,
        COALESCE(e.name_en, '') AS name_en,
        COALESCE(e.sets, 0)::text AS sets,
        COALESCE(e.reps, 0)::text AS reps,
        COALESCE(e.duration, 0)::text AS duration,
        COALESCE(e.image_url, '') AS image_url,
        COALESCE(e.video_url, '') AS video_url,
        COALESCE(e.benefits, '') AS benefits,
        COALESCE(e.tips, '') AS tips,
        COALESCE(m.name_th, '') AS muscle_name_th,  -- ดึง name_th แทน name_en
        s.step_number,
        COALESCE(s.description, '') AS description
      FROM exercises e
      LEFT JOIN exercise_muscles em ON em.exercise_id = e.exercise_id
      LEFT JOIN muscles m ON m.muscle_id = em.muscle_id
      LEFT JOIN exercise_steps s ON s.exercise_id = e.exercise_id
      ORDER BY e.exercise_id, s.step_number
    `;

    const { rows } = await pool.query(sql);
    const map = new Map();

    for (const row of rows) {
      if (!map.has(row.exercise_id)) {
        map.set(row.exercise_id, {
          id: row.exercise_id,
          name: row.name_en,
          sets: row.sets,
          reps: row.reps,
          duration: row.duration,
          image_url: row.image_url,
          video_url: row.video_url,
          benefits: row.benefits,
          tips: row.tips,
          muscles: new Set(),
          steps: [],
        });
      }

      const ex = map.get(row.exercise_id);

      if (row.muscle_name_th) ex.muscles.add(row.muscle_name_th);

      if (row.step_number != null && row.description) {
        const exists = ex.steps.some(
          (s) => s.step === row.step_number && s.desc === row.description
        );
        if (!exists) {
          ex.steps.push({ step: row.step_number, desc: row.description });
        }
      }
    }

    const result = Array.from(map.values()).map((ex) => ({
      ...ex,
      muscles: Array.from(ex.muscles),  // แปลง Set เป็น Array
      steps: ex.steps.sort((a, b) => a.step - b.step).map((s) => s.desc),
    }));

    res.json(result);
  } catch (err) {
    res.status(500).json({
      error: "Failed to fetch exercises",
      detail: err.message,
    });
  }
});

module.exports = router;
