const express = require("express");
const bcrypt = require("bcrypt");
const pool = require("../db");
const transporter = require("../config/email");
const { isStrongPassword } = require("../utils/password");
const { validateEmailAddress } = require("../utils/emailValidator");
const { createEmailTemplate } = require("../utils/emailTemplate");

const router = express.Router();

// SIGNUP
router.post("/signup", async (req, res) => {
  const { username, email, password } = req.body;
  if (!username || !email || !password)
    return res.status(400).json({ error: "Missing fields" });

  if (!isStrongPassword(password))
    return res.status(400).json({ error: "Password too weak" });

  try {
    if (!(await validateEmailAddress(email)))
      return res.status(400).json({ error: "Invalid email domain" });

    const existingEmail = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (existingEmail.rows.length > 0) {
      const user = existingEmail.rows[0];
      if (user.is_verified) {
        return res.status(400).json({ error: "Email already exists and verified" });
      } else {
        const newCode = Math.floor(100000 + Math.random() * 900000).toString();
        await pool.query("UPDATE users SET username = $1 WHERE email = $2", [username, email]);
        await pool.query("DELETE FROM email_verification WHERE email = $1", [email]);
        await pool.query("INSERT INTO email_verification (email, code) VALUES ($1, $2)", [email, newCode]);

        await transporter.sendMail({
          from: `"SkeletonFit App" <${process.env.EMAIL_USER}>`,
          to: email,
          subject: "Resend Verification Code - SkeletonFit App",
          html: createEmailTemplate(
            "Verify your SkeletonFit account again",
            `Hello ${username}, here is your new verification code:`,
            newCode
          ),
        });

        return res.status(200).json({
          message: "Email already registered but not verified. Sent new code.",
          needs_verification: true,
        });
      }
    }

    const existingUsername = await pool.query("SELECT * FROM users WHERE username = $1", [username]);
    if (existingUsername.rows.length > 0)
      return res.status(400).json({ error: "Username already taken" });

    const hashed = await bcrypt.hash(password, 10);

    // ใส่ role ให้ชัดเจน (ถ้า DB มี DEFAULT 'user' อยู่แล้ว จะเหมือนเดิม)
    await pool.query(
      "INSERT INTO users (username, email, password, is_verified, role) VALUES ($1, $2, $3, $4, $5)",
      [username, email, hashed, false, "user"]
    );

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    await pool.query("DELETE FROM email_verification WHERE email = $1", [email]);
    await pool.query("INSERT INTO email_verification (email, code) VALUES ($1, $2)", [email, code]);

    await transporter.sendMail({
      from: `"SkeletonFit App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "Verify your SkeletonFit App account",
      html: createEmailTemplate(
        "Verify your SkeletonFit App account",
        `Hello ${username}, here is your verification code:`,
        code
      ),
    });

    res.status(201).json({
      message: "Signed up successfully. Please verify your email.",
      needs_verification: true,
    });
  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({ error: "Server error", detail: err.message });
  }
});

// VERIFY EMAIL
router.post("/verify", async (req, res) => {
  const { email, code } = req.body;
  if (!email || !code) return res.status(400).json({ error: "Missing fields" });

  try {
    await pool.query("DELETE FROM email_verification WHERE created_at < NOW() - INTERVAL '5 minutes'");

    const result = await pool.query(
      `SELECT * FROM email_verification
       WHERE email = $1 AND code = $2
       AND created_at >= NOW() - INTERVAL '5 minutes'`,
      [email, code]
    );

    if (result.rows.length === 0)
      return res.status(400).json({ error: "Invalid or expired code" });

    await pool.query("UPDATE users SET is_verified = true WHERE email = $1", [email]);
    await pool.query("DELETE FROM email_verification WHERE email = $1", [email]);

    res.json({ message: "Email verified successfully!" });
  } catch (err) {
    res.status(500).json({ error: "Verification failed", detail: err.message });
  }
});

// RESEND OTP
router.post("/resend-otp", async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: "Missing email" });

  try {
    const userResult = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (userResult.rows.length === 0) return res.status(404).json({ error: "Email not found" });

    const user = userResult.rows[0];
    if (user.is_verified) return res.status(400).json({ error: "Email already verified" });

    const newCode = Math.floor(100000 + Math.random() * 900000).toString();
    await pool.query("DELETE FROM email_verification WHERE email = $1", [email]);
    await pool.query("INSERT INTO email_verification (email, code) VALUES ($1, $2)", [email, newCode]);

    await transporter.sendMail({
      from: `"SkeletonFit App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "Resend Verification Code - SkeletonFit App",
      html: createEmailTemplate(
        "Verify your SkeletonFit account again",
        `Hello, here is your new verification code:`,
        newCode
      ),
    });

    res.status(200).json({ message: "OTP resent successfully" });
  } catch (err) {
    console.error("Resend OTP error:", err);
    res.status(500).json({ error: "Server error", detail: err.message });
  }
});

// LOGIN
router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ error: "Missing credentials" });

  try {
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (result.rows.length === 0)
      return res.status(404).json({ error: "User not found" });

    const user = result.rows[0];
    if (!user.is_verified)
      return res.status(400).json({ error: "Email not verified" });

    const match = await bcrypt.compare(password, user.password);
    if (!match)
      return res.status(401).json({ error: "Incorrect password" });

    res.json({
      message: "Login successful",
      user: {
        user_id: user.user_id,
        username: user.username,
        email: user.email,
        role: user.role,    
      },
    });
  } catch (err) {
    res.status(500).json({ error: "Login error", detail: err.message });
  }
});

// REQUEST RESET OTP
router.post("/request-reset-otp", async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: "Missing email" });

  try {
    const userResult = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (userResult.rows.length === 0)
      return res.status(404).json({ error: "Email not found" });

    const user = userResult.rows[0];
    if (!user.is_verified)
      return res.status(400).json({ error: "Email not verified" });

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    await pool.query("DELETE FROM email_verification WHERE email = $1", [email]);
    await pool.query("INSERT INTO email_verification (email, code) VALUES ($1, $2)", [email, code]);

    await transporter.sendMail({
      from: `"SkeletonFit App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "Reset Password - SkeletonFit App",
      html: createEmailTemplate("Reset Your Password", "Use the OTP below to reset your password:", code),
    });

    res.status(200).json({ message: "OTP sent to your email" });
  } catch (err) {
    console.error("Request OTP error:", err);
    res.status(500).json({ error: "Server error", detail: err.message });
  }
});

// RESET PASSWORD WITH OTP
router.post("/reset-password-otp", async (req, res) => {
  const { email, otp, newPassword } = req.body;
  if (!email || !otp || !newPassword)
    return res.status(400).json({ error: "Missing fields" });

  if (!isStrongPassword(newPassword))
    return res.status(400).json({ error: "Password too weak" });

  try {
    await pool.query("DELETE FROM email_verification WHERE created_at < NOW() - INTERVAL '5 minutes'");

    const verify = await pool.query(
      `SELECT * FROM email_verification
       WHERE email = $1 AND code = $2
       AND created_at >= NOW() - INTERVAL '5 minutes'`,
      [email, otp]
    );

    if (verify.rows.length === 0)
      return res.status(400).json({ error: "Invalid or expired OTP" });

    const userResult = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    const user = userResult.rows[0];

    const isSame = await bcrypt.compare(newPassword, user.password);
    if (isSame) {
      return res.status(400).json({ error: "New password must be different from the old one" });
    }

    const hashed = await bcrypt.hash(newPassword, 10);
    await pool.query("UPDATE users SET password = $1 WHERE email = $2", [hashed, email]);
    await pool.query("DELETE FROM email_verification WHERE email = $1", [email]);

    res.status(200).json({ message: "Password reset successful" });
  } catch (err) {
    console.error("Reset password error:", err);
    res.status(500).json({ error: "Server error", detail: err.message });
  }
});

module.exports = router;
