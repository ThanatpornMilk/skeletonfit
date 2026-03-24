const express = require('express');
const router = express.Router();
const pool = require('../db');

// ดึงข้อมูลกล้ามเนื้อทั้งหมด
router.get('/', async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT muscle_id, name_th, name_en FROM muscles ORDER BY muscle_id ASC`
    );
    res.json(rows);
  } catch (e) {
    console.error('Error fetching muscles:', e);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
