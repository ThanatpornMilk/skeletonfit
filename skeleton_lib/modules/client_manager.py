import time

class Client:
    def __init__(self, cid):
        self.cid = cid
        self.selected_pose = None

        # counters & states
        self.reps_counts = {}
        self.hold_times = {}
        self.last_ts = time.time()
        self.pose_states = {}
        self.last_confidence = {}
        self.last_rep_time = {}
        self.peak_detected = {}
        self.confidence_history = {}

        # twist state
        self.twist_direction = "center"  # สำหรับ Russian Twist

        # latch สำหรับกันค้างในโหมด continuous (ยกเว้นท่าที่ถูก exempt)
        self.high_latch = {}  # pose -> bool


class ClientManager:
    # ท่าที่ "ยกเว้น" ไม่ใส่ latch (ปล่อยให้นับด้วย cooldown อย่างเดียว)
    EXEMPT_CONTINUOUS = {"Push-ups", "Dead Bug"}

    COOLDOWN = {
        "Bodyweight Squat": 0.8,
        "Push-ups": 2.0,
        "Sit-ups": 0.8,
        "Lunge (Split Squat)": 0.8,
        "Dead Bug": 1.9,
        "Russian Twist": 0.5,
        "Lying Leg Raises": 1.0,
    }

    POSE_THRESHOLDS = {
        "Bodyweight Squat": {
            "high": 0.50, "low": 0.30, "smooth_frames": 2, "count_mode": "peak_to_low"
        },
        # Push-ups: continuous + exempt latch (ยังนับด้วย cooldown ได้แม้ค้าง)
        "Push-ups": {
            "high": 0.75, "continuous": True, "use_raw": True
        },
        "Sit-ups": {
            "high": 0.45, "low": 0.28, "smooth_frames": 2, "count_mode": "peak_to_low"
        },
        "Plank": {
            "high": 0.55, "low": 0.35, "smooth_frames": 3, "count_mode": "hold"
        },
        "Side Plank": {
            "high": 0.55, "low": 0.35, "smooth_frames": 3, "count_mode": "hold"
        },
        # Dead Bug: continuous + exempt latch (ยังนับด้วย cooldown ได้แม้ค้าง)
        "Dead Bug": {
            "high": 0.75, "continuous": True, "use_raw": True
        },
        # Lying Leg Raises: continuous + มี latch กันค้าง (เพราะไม่ได้อยู่ใน EXEMPT_CONTINUOUS)
        "Lying Leg Raises": {
            "high": 0.75, "continuous": True, "use_raw": True
            # ไม่มี low ก็ได้ เดี๋ยวใช้ default low=0.45 สำหรับ unlock
        },
        "Russian Twist": {
            "high": 0.30, "low": 0.10, "smooth_frames": 1,
            "count_mode": "direction_twist", "use_raw": True, "angle_tolerance": 0.10
        },
    }

    DEFAULT_THRESHOLD = {"high": 0.45, "low": 0.28, "smooth_frames": 2}
    HOLD_THRESHOLD = 0.55
    HOLD_MIN_DURATION = 0.3

    def __init__(self):
        self.clients = {}

    # ---------------- Client lifecycle ----------------
    def register(self, host):
        """ลงทะเบียน client ใหม่"""
        cid = f"{host}_{int(time.time() * 1000)}"
        self.clients[cid] = Client(cid)
        return cid

    def remove(self, cid):
        """ลบ client ออกจากระบบ"""
        if cid in self.clients:
            del self.clients[cid]

    # ---------------- Pose selection ----------------
    def get_pose(self, cid):
        """Return current selected pose of the client"""
        client = self.clients.get(cid)
        if client:
            return client.selected_pose
        return None

    def set_selected_pose(self, cid, pose):
        """Set the selected pose for the client"""
        if cid in self.clients:
            client = self.clients[cid]
            client.selected_pose = pose
            if pose not in client.reps_counts:
                client.reps_counts[pose] = 0
            if pose not in client.pose_states:
                client.pose_states[pose] = "low"
            if pose not in client.last_confidence:
                client.last_confidence[pose] = 0.0
            if pose not in client.last_rep_time:
                client.last_rep_time[pose] = 0.0
            if pose not in client.confidence_history:
                client.confidence_history[pose] = []
            if pose not in client.hold_times:
                client.hold_times[pose] = {"current": 0.0, "best": 0.0}
            # reset latch ของท่านี้
            client.high_latch[pose] = False
            # reset ทิศ twist
            client.twist_direction = "center"

    # ---------------- Helpers ----------------
    def get_hold_time(self, cid, pose):
        """Return current and best hold times (dict)"""
        client = self.clients.get(cid)
        if not client:
            return {"current": 0.0, "best": 0.0}
        block = client.hold_times.get(pose, {"current": 0.0, "best": 0.0})
        # ป้องกันชนิดไม่ตรง
        current = float(block.get("current", 0.0) or 0.0)
        best = float(block.get("best", 0.0) or 0.0)
        return {"current": current, "best": best}

    def _get_thresholds(self, pose):
        return self.POSE_THRESHOLDS.get(pose, self.DEFAULT_THRESHOLD)

    def _check_cooldown(self, client, pose, ts):
        cooldown = self.COOLDOWN.get(pose, 0.7)
        last_time = client.last_rep_time.get(pose, 0)
        return (ts - last_time) >= cooldown

    def _smooth_confidence(self, client, pose, confidence):
        thresholds = self._get_thresholds(pose)
        if thresholds.get("use_raw", False):
            return confidence
        max_frames = thresholds.get("smooth_frames", 2)
        hist = client.confidence_history.setdefault(pose, [])
        hist.append(confidence)
        if len(hist) > max_frames:
            hist.pop(0)
        return sum(hist) / len(hist)

    # ---------------- Core update ----------------
    def update_counters(self, cid, pose, confidence, ts, full_body_visible=True):
        client = self.clients.get(cid)
        if not client or not pose:
            return

        thresholds = self._get_thresholds(pose)
        high = thresholds.get("high", 0.5)
        low = thresholds.get("low", 0.3)
        count_mode = thresholds.get("count_mode", "peak_to_low")
        continuous = thresholds.get("continuous", False)
        use_raw = thresholds.get("use_raw", False)
        conf = confidence if use_raw else self._smooth_confidence(client, pose, confidence)

        # (1) HOLD mode (Plank, Side Plank)
        if count_mode == "hold":
            hold = client.hold_times.get(pose, {"current": 0.0, "best": 0.0})
            dt = ts - client.last_ts
            if full_body_visible and conf > self.HOLD_THRESHOLD:
                hold["current"] += max(0.0, dt)
            else:
                if hold["current"] > self.HOLD_MIN_DURATION:
                    hold["best"] = max(hold["best"], hold["current"])
                hold["current"] = 0.0
            client.hold_times[pose] = hold
            client.last_confidence[pose] = conf
            client.last_ts = ts
            return

        # (2) Continuous mode
        if continuous:
            # 2.1 ท่าที่ "ยกเว้น" (Push-ups, Dead Bug): ไม่ใส่ latch -> นับด้วย cooldown ได้แม้ค้าง
            if pose in self.EXEMPT_CONTINUOUS:
                if conf >= high and self._check_cooldown(client, pose, ts):
                    client.reps_counts[pose] = client.reps_counts.get(pose, 0) + 1
                    client.last_rep_time[pose] = ts
                    # debug: print(f"[{pose}] 🔁 (EXEMPT) REP #{client.reps_counts[pose]} conf={conf:.2f}")
                client.last_confidence[pose] = conf
                client.last_ts = ts
                return

            # 2.2 ท่า continuous อื่น ๆ: ใส่ latch กันค้าง (ต้องตกต่ำกว่า low_unlock ก่อนนับรอบถัดไป)
            latched = client.high_latch.get(pose, False)
            # ใช้ low_unlock ผ่อนปรนเล็กน้อย (กันกรณี conf ไม่ลงถึง low เป๊ะ ๆ)
            low_unlock = min(0.97, thresholds.get("low", 0.45) + 0.03)

            # นับได้เฉพาะตอน "ยังไม่ล็อก" และ conf >= high และ cooldown ผ่าน
            if (not latched) and conf >= high and self._check_cooldown(client, pose, ts):
                client.reps_counts[pose] = client.reps_counts.get(pose, 0) + 1
                client.last_rep_time[pose] = ts
                client.high_latch[pose] = True  # ล็อกทันทีหลังนับ
                # debug: print(f"[{pose}] 🔁 (LATCH) REP #{client.reps_counts[pose]} conf={conf:.2f}")

            # ปลดล็อกเมื่อกลับสู่ท่าเตรียม (ต่ำกว่า low_unlock)
            if conf < low_unlock:
                client.high_latch[pose] = False

            client.last_confidence[pose] = conf
            client.last_ts = ts
            return

        # (3) Direction twist (Russian Twist) — ต้องเปลี่ยนทิศจริง
        if count_mode == "direction_twist":
            tol = thresholds.get("angle_tolerance", 0.1)
            direction_now = "center"
            if conf > high + tol:
                direction_now = "right"
            elif conf < low - tol:
                direction_now = "left"

            if direction_now != client.twist_direction and direction_now in ("left", "right"):
                if self._check_cooldown(client, pose, ts):
                    client.reps_counts[pose] = client.reps_counts.get(pose, 0) + 0.5
                    client.last_rep_time[pose] = ts
                    # debug: print(f"[{pose}] 🔄 {direction_now} REP #{client.reps_counts[pose]} conf={conf:.2f}")
            client.twist_direction = direction_now
            client.last_confidence[pose] = conf
            client.last_ts = ts
            return

        # (4) Default (peak_to_low / on_peak)
        current_state = client.pose_states.get(pose, "low")

        if count_mode == "on_peak":
            # นับตอนกระทบยอด (ข้าม high) แต่ต้องกลับลงต่ำกว่า low ก่อนจะนับยอดถัดไป
            if current_state == "low" and conf >= high:
                if self._check_cooldown(client, pose, ts):
                    client.reps_counts[pose] = client.reps_counts.get(pose, 0) + 1
                    client.last_rep_time[pose] = ts
                client.pose_states[pose] = "high"
            elif current_state == "high" and conf < low:
                client.pose_states[pose] = "low"
        else:
            # peak_to_low: ขึ้น high -> กลับ low -> นับ 1 ครั้ง
            if current_state == "low" and conf >= high:
                client.pose_states[pose] = "high"
            elif current_state == "high" and conf < low:
                if self._check_cooldown(client, pose, ts):
                    client.reps_counts[pose] = client.reps_counts.get(pose, 0) + 1
                    client.last_rep_time[pose] = ts
                client.pose_states[pose] = "low"

        client.last_confidence[pose] = conf
        client.last_ts = ts

    # ---------------- Debug/Responses ----------------
    def get_state_debug(self, cid, pose):
        c = self.clients.get(cid)
        if not c:
            return "N/A"
        conf = c.last_confidence.get(pose, 0)
        reps = c.reps_counts.get(pose, 0)
        state = c.pose_states.get(pose, "low")
        return f"{pose}: {state}, conf={conf:.2f}, reps={reps}"

    def make_response(self, cid, pose, ts):
        c = self.clients.get(cid)
        if not c:
            return {"status": "error", "message": "client not found"}
        return {
            "status": "ok",
            "pose": pose,
            "reps": c.reps_counts,
            "last_conf": round(c.last_confidence.get(pose, 0), 2),
            "state": c.pose_states.get(pose, "low")
        }
