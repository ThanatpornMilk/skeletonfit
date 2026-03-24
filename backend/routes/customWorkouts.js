const express = require("express");
const pool = require("../db");
const router = express.Router();

/**
 * CREATE custom workout
 * body: { user_id, name, exercises: [exercise_id1, exercise_id2, ...] }
 * - เก็บลำดับตาม index ของอาร์เรย์ (เริ่มที่ 1)
 * - บันทึก created_at = NOW()
 */
router.post("/custom_workouts", async (req, res) => {
  const { user_id, name, exercises } = req.body;
  if (!user_id || !name || !Array.isArray(exercises)) {
    return res.status(400).json({ error: "Invalid request body" });
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const workoutRes = await client.query(
      `INSERT INTO custom_workouts (user_id, name, created_at)
       VALUES ($1, $2, NOW())
       RETURNING custom_workouts_id AS id, created_at`,
      [user_id, name]
    );
    const workoutId = workoutRes.rows[0].id;

    for (let i = 0; i < exercises.length; i++) {
      await client.query(
        `INSERT INTO custom_workout_exercises
           (custom_workouts_id, exercise_id, order_in_routine)
         VALUES ($1, $2, $3)`,
        [workoutId, exercises[i], i + 1]
      );
    }

    await client.query("COMMIT");
    return res
      .status(201)
      .json({
        message: "Custom workout saved",
        workout_id: workoutId,
        created_at: workoutRes.rows[0].created_at
      });
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("Error saving custom workout:", err);
    return res
      .status(500)
      .json({ error: "Failed to save custom workout", detail: err.message });
  } finally {
    client.release();
  }
});

/**
 * GET custom workouts ของ user พร้อม exercises (ครบ: tips / steps / muscles)
 * - เรียงลำดับท่าใน routine ตาม order_in_routine
 * - ทั้งรายการ custom workout เรียงใหม่สุดอยู่บนสุด (created_at DESC, id DESC)
 */
router.get("/custom_workouts/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(
      `
      SELECT 
        cw.custom_workouts_id AS id,
        cw.name               AS workout_name,
        cw.created_at,
        ce.order_in_routine,
        e.exercise_id,
        e.name_en,
        e.image_url,
        e.sets,
        e.reps,
        e.duration,
        e.benefits,
        COALESCE(e.tips, '') AS tips,

        /* steps: JSON array ของคำอธิบาย เรียงตาม step_number */
        (
          SELECT COALESCE(json_agg(es.description ORDER BY es.step_number), '[]'::json)
          FROM exercise_steps es
          WHERE es.exercise_id = e.exercise_id
        ) AS steps,

        /* muscles: JSON array ของ "ชื่อกล้ามเนื้อภาษาไทย" (กันซ้ำด้วย DISTINCT) */
        (
          SELECT COALESCE(
                   json_agg(DISTINCT m.name_th ORDER BY m.name_th),
                   '[]'::json
                 )
          FROM exercise_muscles em
          JOIN muscles m ON m.muscle_id = em.muscle_id
          WHERE em.exercise_id = e.exercise_id
        ) AS muscles

      FROM custom_workouts cw
      JOIN custom_workout_exercises ce 
        ON cw.custom_workouts_id = ce.custom_workouts_id
      JOIN exercises e 
        ON ce.exercise_id = e.exercise_id
      WHERE cw.user_id = $1
      ORDER BY cw.created_at DESC, cw.custom_workouts_id DESC, ce.order_in_routine ASC
      `,
      [userId]
    );

    // group by workout id -> exercises[]
    const workouts = [];
    for (const row of result.rows) {
      let w = workouts.find(x => x.id === row.id);
      if (!w) {
        w = {
          id: row.id,
          workout_name: row.workout_name,
          created_at: row.created_at,
          exercises: [],
        };
        workouts.push(w);
      }

      w.exercises.push({
        id: row.exercise_id,
        name_en: row.name_en || "",
        image_url: row.image_url || "",
        sets: (row.sets ?? "").toString(),
        reps: (row.reps ?? "").toString(),
        duration: (row.duration ?? "").toString(),
        benefits: row.benefits ?? "",
        tips: row.tips ?? "",
        steps: row.steps ?? [],
        muscles: row.muscles ?? [],
        order_in_routine: row.order_in_routine,
      });
    }

    return res.status(200).json(workouts);
  } catch (err) {
    console.error("Error fetching custom workouts:", err);
    return res.status(500).json({ error: "Failed to fetch custom workouts", detail: err.message });
  }
});

module.exports = router;
