#!/bin/bash

# สคริปต์สำหรับหยุดและลบ Container ทั้งหมด

echo "🛑 กำลังหยุดและลบ Container ของโหมด Development..."

docker-compose \
  -f docker-compose.yml \
  -f docker-compose.dev.yml \
  down

echo "✅ ระบบหยุดทำงานเรียบร้อยแล้ว"
