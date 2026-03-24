const express = require('express');
const router  = express.Router();
const pool    = require('../db');

router.post('/', async (req, res) => {
  try {
    const {
      user_id,
      name_en,
      sets,
      reps,
      benefits,
      tips,
      duration_seconds,     // int (วินาที) หรือ null
      muscle_id1,
      muscle_id2,
      muscle_id3,
      muscle_id4,
      muscle_id5,
      exercise_steps1,
      exercise_steps2,
      exercise_steps3,
      exercise_steps4,
      exercise_steps5,
    } = req.body;

    const sql = `
      INSERT INTO request (
        user_id, name_en, sets, reps, benefits, tips, duration,
        muscle_id1, muscle_id2, muscle_id3, muscle_id4, muscle_id5,
        exercise_steps1, exercise_steps2, exercise_steps3, exercise_steps4, exercise_steps5
      )
      VALUES (
        $1::int, $2::text, $3::int, $4::int, $5::text, $6::text,
        $7::int,              -- ✅ duration เป็น INT ตรง ๆ
        $8::int, $9::int, $10::int, $11::int, $12::int,
        $13::text, $14::text, $15::text, $16::text, $17::text
      )
      RETURNING request_id;
    `;

    const params = [
      user_id,
      name_en,
      sets,
      (reps ?? null),
      benefits,
      tips,
      (duration_seconds ?? null),   // ถ้าไม่ส่งมาก็เป็น null
      muscle_id1,
      (muscle_id2 ?? null),
      (muscle_id3 ?? null),
      (muscle_id4 ?? null),
      (muscle_id5 ?? null),
      (exercise_steps1 ?? null),
      (exercise_steps2 ?? null),
      (exercise_steps3 ?? null),
      (exercise_steps4 ?? null),
      (exercise_steps5 ?? null),
    ];

    const { rows } = await pool.query(sql, params);
    return res.status(201).json({ request_id: rows?.[0]?.request_id ?? 0 });
  } catch (err) {
    console.error('POST /requests error:', err);
    return res
      .status(500)
      .json({ error: 'Internal Server Error', code: err.code, detail: err.detail });
  }
});

module.exports = router;
