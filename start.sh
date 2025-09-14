#!/bin/bash

# สคริปต์สำหรับเริ่มสภาพแวดล้อมการพัฒนา (Development Environment)

echo "🚀 กำลังเริ่มระบบทั้งหมดในโหมด Development..."

docker-compose \
  -f docker-compose.yml \
  -f docker-compose.dev.yml \
  up --build -d

echo "✅ ระบบเริ่มทำงานเรียบร้อยแล้ว! ใช้ 'docker-compose ps' เพื่อดูสถานะ"

