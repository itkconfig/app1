#!/bin/bash
#
# สคริปต์อเนกประสงค์สำหรับ Debug Docker Compose Project
# วิธีใช้: ./debug-dev.sh [คำสั่ง] [ชื่อ service]
#
# ตัวอย่าง:
#   ./debug-dev.sh status          -> ดูสถานะของทุก container
#   ./debug-dev.sh logs custom-app -> ดู log ของ custom-app
#   ./debug-dev.sh shell custom-app  -> เข้าไปใน shell ของ custom-app
#

# --- ค่าคงที่ ---
FILES="-f docker-compose.yml -f docker-compose.dev.yml"
COMMAND=$1
SERVICE=$2

# --- ฟังก์ชันช่วยเหลือ ---
show_help() {
  echo "วิธีใช้: ./debug-dev.sh [คำสั่ง] [ชื่อ service (ถ้าจำเป็น)]"
  echo ""
  echo "คำสั่งที่ใช้ได้:"
  echo "  status            ดูสถานะย่อของทุก containers (docker-compose ps)"
  echo "  logs [service]    ดู logs ของ service ที่ระบุ (หรือทั้งหมดถ้าไม่ระบุ)"
  echo "  shell <service>   เข้าไปใน shell ของ container ที่ระบุ (จำเป็นต้องระบุ service)"
  echo "  inspect <service> ดูข้อมูลเชิงลึกทั้งหมดของ container (JSON)"
  echo "  top <service>     ดู process ที่กำลังรันอยู่ใน container"
  echo "  stats             ดูสถิติการใช้ CPU/Memory/Network แบบ real-time"
  echo "  networks          แสดงรายชื่อ network ทั้งหมดของโปรเจกต์"
  echo "  volumes           แสดงรายชื่อ volume ทั้งหมดของโปรเจกต์"
  echo "  config            แสดงผลลัพธ์การรวมไฟล์ compose ทั้งหมด (มีประโยชน์มาก)"
  echo "  rebuild <service> บังคับ build image ของ service ใหม่ทั้งหมด"
  echo ""
}

# --- Main Logic ---
case $COMMAND in
  status)
    echo "--- สถานะของ Containers ---"
    docker-compose $FILES ps
    ;;

  logs)
    echo "--- กำลังแสดง Logs (กด Ctrl+C เพื่อออก) ---"
    if [ -z "$SERVICE" ]; then
      docker-compose $FILES logs --tail="100" -f
    else
      docker-compose $FILES logs --tail="100" -f "$SERVICE"
    fi
    ;;

  shell)
    if [ -z "$SERVICE" ]; then
      echo "❌ Error: กรุณาระบุชื่อ service ที่ต้องการเข้าไป"
      show_help
      exit 1
    fi
    echo "--- กำลังเข้าไปใน Shell ของ '$SERVICE' (พิมพ์ 'exit' เพื่อออก) ---"
    docker-compose $FILES exec "$SERVICE" sh
    ;;

  inspect)
    if [ -z "$SERVICE" ]; then
      echo "❌ Error: กรุณาระบุชื่อ service ที่ต้องการ inspect"
      show_help
      exit 1
    fi
    echo "--- แสดงข้อมูล Inspect ของ '$SERVICE' ---"
    docker-compose $FILES ps -q "$SERVICE" | xargs docker inspect
    ;;
    
  top)
    if [ -z "$SERVICE" ]; then
      echo "❌ Error: กรุณาระบุชื่อ service ที่ต้องการดู top"
      show_help
      exit 1
    fi
    echo "--- Process ที่กำลังรันใน '$SERVICE' ---"
    docker-compose $FILES top "$SERVICE"
    ;;

  stats)
    echo "--- สถิติการใช้งาน Resource (กด Ctrl+C เพื่อออก) ---"
    docker stats
    ;;
    
  networks)
    echo "--- Networks ที่ถูกสร้างโดย Docker Compose ---"
    docker-compose $FILES ps -q | xargs docker inspect -f '{{.Name}} - {{.State.Status}} - {{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}'
    echo ""
    echo "--- Networks ทั้งหมดใน Docker ---"
    docker network ls
    ;;

  volumes)
    echo "--- Volumes ทั้งหมดใน Docker ---"
    docker volume ls
    ;;

  config)
    echo "--- ผลลัพธ์การรวมไฟล์ docker-compose.yml ทั้งหมด ---"
    docker-compose $FILES config
    ;;

  rebuild)
     if [ -z "$SERVICE" ]; then
      echo "❌ Error: กรุณาระบุชื่อ service ที่ต้องการ rebuild"
      show_help
      exit 1
    fi
    echo "--- กำลังบังคับ Rebuild Image ของ '$SERVICE' ---"
    docker-compose $FILES build --no-cache "$SERVICE"
    echo "✅ Rebuild เสร็จสิ้น! รัน './start-dev.sh' เพื่อเริ่มระบบ"
    ;;
    
  *)
    show_help
    exit 1
    ;;
esac
