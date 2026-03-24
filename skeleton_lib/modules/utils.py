# modules/utils.py
import numpy as np
import math

def landmark_xy(lm):
    ## ดึงค่าพิกัด (x, y) จากวัตถุเป็น landmark(lm) ของ Mediapipe
    return (lm.x, lm.y)

def angle(a, b, c):
    ## คำนวณมุม ระหว่างจุด A-B-C ว่ากี่องศา ใช้ในกรณีที่ต้องการวัดมุมข้อต่างๆ เช่น เข่า, ศอก, สะโพก
    a, b, c = np.array(a), np.array(b), np.array(c) #จุด a b c คือพิกัดของ landmark แล้วแปลงเป็น array เพื่อเอาไปคำนวนเชิงเวกเตอร์ได้สะดวก
    ba, bc = a - b, c - b # ba,bc คือเวกเตอร์จาก b -> a , b -> c เช่นจุด b=เข่า,a=สะโพก,c=ข้อเท้า มุมที่เราคำนวณคือ มุมที่ข้อเข่า (B)
    norm_ba, norm_bc = np.linalg.norm(ba), np.linalg.norm(bc)
    if norm_ba < 1e-6 or norm_bc < 1e-6:
        return 0.0
    cosang = np.clip(np.dot(ba, bc) / (norm_ba * norm_bc), -1.0, 1.0)
    return math.degrees(math.acos(cosang))

def check_visibility(lm, threshold=0.5):
    ## ตรวจสอบว่า landmark มีค่า visibility (ความชัดเจนของจุดในภาพ) มากกว่าค่ากำหนดหรือไม่
    return lm.visibility > threshold if hasattr(lm, "visibility") else True

def check_full_body_visible(landmarks, mp_pose, min_visibility=0.5):
    ## ตรวจสอบว่าเห็นร่างกายเต็มตัวหรือไม่ ต้องเห็นจุดสำคัญ: ไหล่, สะโพก, เข่า, ข้อเท้า ทั้งซ้ายและขวา

    required_landmarks = [
        "LEFT_SHOULDER", "RIGHT_SHOULDER",
        "LEFT_HIP", "RIGHT_HIP",
        "LEFT_KNEE", "RIGHT_KNEE",
        "LEFT_ANKLE", "RIGHT_ANKLE"
    ]
    name_th = {
        "LEFT_SHOULDER": "ไหล่ซ้าย",
        "RIGHT_SHOULDER": "ไหล่ขวา",
        "LEFT_HIP": "สะโพกซ้าย",
        "RIGHT_HIP": "สะโพกขวา",
        "LEFT_KNEE": "เข่าซ้าย",
        "RIGHT_KNEE": "เข่าขวา",
        "LEFT_ANKLE": "ข้อเท้าซ้าย",
        "RIGHT_ANKLE": "ข้อเท้าขวา"
    }
    
    missing_parts = []
    visible_count = 0
    total_visibility = 0.0
    
    for landmark_name in required_landmarks:
        try:
            idx = getattr(mp_pose.PoseLandmark, landmark_name).value
            lm = landmarks[idx]
            visibility = lm.visibility if hasattr(lm, "visibility") else 1.0
            total_visibility += visibility

            if visibility >= min_visibility:
                visible_count += 1
            else:
                missing_parts.append(name_th.get(landmark_name, landmark_name))
        except Exception:
            missing_parts.append(name_th.get(landmark_name, landmark_name))

    is_visible = visible_count >= 6
    visibility_score = total_visibility / len(required_landmarks)

    return is_visible, missing_parts, visibility_score

def check_pose_specific_visibility(landmarks, mp_pose, pose_name, min_visibility=0.5):

    ##ตรวจสอบว่าเห็นจุดสำคัญเฉพาะของแต่ละท่าไหม
    pose_requirements = {
        "Bodyweight Squat": ["LEFT_HIP", "RIGHT_HIP", "LEFT_KNEE", "RIGHT_KNEE", 
                             "LEFT_ANKLE", "RIGHT_ANKLE", "LEFT_SHOULDER", "RIGHT_SHOULDER"],
        "Push-ups": ["LEFT_SHOULDER", "RIGHT_SHOULDER", "LEFT_ELBOW", "RIGHT_ELBOW",
                     "LEFT_WRIST", "RIGHT_WRIST", "LEFT_HIP", "RIGHT_HIP"],
        "Plank": ["LEFT_SHOULDER", "RIGHT_SHOULDER", "LEFT_HIP", "RIGHT_HIP",
                  "LEFT_ANKLE", "RIGHT_ANKLE"],
        "Sit-ups": ["LEFT_SHOULDER", "RIGHT_SHOULDER", "LEFT_HIP", "RIGHT_HIP"],
        "Lunge (Split Squat)": ["LEFT_HIP", "RIGHT_HIP", "LEFT_KNEE", "RIGHT_KNEE",
                                 "LEFT_ANKLE", "RIGHT_ANKLE"],
        "Dead Bug": ["LEFT_WRIST", "RIGHT_WRIST", "LEFT_ANKLE", "RIGHT_ANKLE",
                     "LEFT_SHOULDER", "RIGHT_SHOULDER"],
        "Side Plank": ["RIGHT_SHOULDER", "RIGHT_HIP", "RIGHT_ANKLE"],
        "Russian Twist": ["LEFT_SHOULDER", "RIGHT_SHOULDER", "LEFT_HIP", "RIGHT_HIP"],
        "Lying Leg Raises": ["LEFT_HIP", "RIGHT_HIP", "LEFT_ANKLE", "RIGHT_ANKLE"]
    }
    
    required = pose_requirements.get(pose_name, [])
    if not required:
        return True, [], 1.0
    # ถ้าไม่เจอในพจนานุกรม ถือว่าไม่ต้องตรวจ
    
    missing = []
    visible_count = 0
    total_visibility = 0.0
    
    for landmark_name in required:
        try:
            idx = getattr(mp_pose.PoseLandmark, landmark_name).value
            lm = landmarks[idx]
            visibility = lm.visibility if hasattr(lm, "visibility") else 1.0
            total_visibility += visibility
            
            if visibility >= min_visibility:
                visible_count += 1
            else:
                missing.append(landmark_name.replace("_", " ").title())
        except Exception:
            missing.append(landmark_name.replace("_", " ").title())
    
    is_visible = visible_count >= len(required) * 0.7
    visibility_score = total_visibility / len(required) if required else 1.0
    
    return is_visible, missing, visibility_score