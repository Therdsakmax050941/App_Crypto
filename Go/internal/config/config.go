package config

import (
    "log"                      // สำหรับการบันทึก log ข้อผิดพลาด
    "os"                       // สำหรับการทำงานกับ environment variables
    "github.com/joho/godotenv" // สำหรับการโหลดไฟล์ .env
)

// Config struct เก็บค่าคอนฟิกูเรชันสำหรับการเชื่อมต่อฐานข้อมูล
type Config struct {
    DBUser     string // ชื่อผู้ใช้ฐานข้อมูล
    DBPassword string // รหัสผ่านฐานข้อมูล
    DBHost     string // โฮสต์ฐานข้อมูล
    DBPort     string // พอร์ตฐานข้อมูล
    DBName     string // ชื่อฐานข้อมูล
}

// LoadConfig ฟังก์ชันสำหรับโหลดค่าคอนฟิกูเรชันจาก environment variables
func LoadConfig() Config {
    // โหลดไฟล์ .env
    if err := godotenv.Load(); err != nil {
        log.Fatal("Error loading .env file") // ถ้าโหลดไฟล์ .env ไม่สำเร็จ ให้บันทึก log ข้อผิดพลาดและหยุดการทำงาน
    }

    // อ่านค่าจาก environment variables และคืนค่า Config struct
    return Config{
        DBUser:     getEnv("DB_USER", "root"),          // ถ้าไม่มีค่าใน environment variable ใช้ "root" เป็นค่าเริ่มต้น
        DBPassword: getEnv("DB_PASSWORD", "password"),  // ถ้าไม่มีค่าใน environment variable ใช้ "password" เป็นค่าเริ่มต้น
        DBHost:     getEnv("DB_HOST", "localhost"),     // ถ้าไม่มีค่าใน environment variable ใช้ "localhost" เป็นค่าเริ่มต้น
        DBPort:     getEnv("DB_PORT", "3306"),          // ถ้าไม่มีค่าใน environment variable ใช้ "3306" เป็นค่าเริ่มต้น
        DBName:     getEnv("DB_NAME", "mydatabase"),    // ถ้าไม่มีค่าใน environment variable ใช้ "mydatabase" เป็นค่าเริ่มต้น
    }
}

// getEnv ฟังก์ชันสำหรับอ่านค่า environment variable ถ้าไม่มี ให้ใช้ค่าเริ่มต้น
func getEnv(key, defaultValue string) string {
    value, exists := os.LookupEnv(key) // ตรวจสอบว่ามีค่า environment variable นี้หรือไม่
    if !exists {
        return defaultValue // ถ้าไม่มี ให้ใช้ค่าเริ่มต้น
    }
    return value // ถ้ามี ให้คืนค่าที่อ่านได้
}
