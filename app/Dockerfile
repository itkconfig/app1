# Dockerfile: /app/Dockerfile (ฉบับแก้ไข)

# --- Stage 1: Base ---
FROM node:18-alpine AS base
WORKDIR /app

# --- Stage 2: Dependencies ---
FROM base AS dependencies


# << เพิ่มส่วนนี้เข้ามา >>
# ติดตั้ง curl เพื่อใช้สำหรับ healthcheck (และเครื่องมืออื่นๆ ที่อาจจำเป็น)
# --no-cache จะไม่เก็บ cache ของ package manager ไว้ ทำให้ image มีขนาดเล็ก
RUN apk add --no-cache curl
# ใช้ Wildcard (*) เพื่อให้ยืดหยุ่น
# COPY package*.json ./ จะคัดลอกทั้ง package.json และ package-lock.json (ถ้ามี)
# ถ้ามีแค่ package.json มันก็จะคัดลอกแค่ไฟล์เดียว และไม่เกิด Error
COPY package*.json ./

# รัน npm install เพื่อติดตั้ง Dependencies
# ถ้ามี package-lock.json, npm จะติดตั้งเวอร์ชันที่ล็อคไว้ ทำให้ build ได้ผลลัพธ์เหมือนเดิมทุกครั้ง
# ถ้าไม่มี, npm จะสร้าง package-lock.json ขึ้นมาใหม่ระหว่างการ build
RUN npm install

# --- Stage 3: Development ---
FROM dependencies AS development

# คัดลอกโค้ดทั้งหมดที่เหลือเข้ามา
COPY . .

# กำหนดคำสั่งเริ่มต้นสำหรับโหมด Development
CMD ["npm", "run", "dev"]
