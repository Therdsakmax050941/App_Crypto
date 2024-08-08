package main

import (
    "database/sql"               // สำหรับการทำงานกับฐานข้อมูล SQL
    "log"                        // สำหรับการบันทึก log
    "myapp/internal/user"        // สำหรับการใช้งาน package user ภายในโปรเจค
    "myapp/internal/config"      // สำหรับการใช้งาน package config ภายในโปรเจค
    _ "github.com/go-sql-driver/mysql" // สำหรับการใช้ driver ของ MySQL
    "github.com/gofiber/fiber/v2"      // สำหรับการใช้งาน web framework Fiber
)

func main() {
    // โหลดการตั้งค่า
    cfg := config.LoadConfig() // เรียกใช้ฟังก์ชัน LoadConfig เพื่อโหลดค่าคอนฟิกูเรชันจาก environment variables

    // สร้าง connection string
    dsn := cfg.DBUser + ":" + cfg.DBPassword + "@tcp(" + cfg.DBHost + ":" + cfg.DBPort + ")/" + cfg.DBName
    db, err := sql.Open("mysql", dsn) // เปิดการเชื่อมต่อฐานข้อมูลด้วย connection string ที่สร้างขึ้น
    if err != nil {
        log.Fatal(err) // ถ้าเปิดการเชื่อมต่อไม่สำเร็จ ให้บันทึก log ข้อผิดพลาดและหยุดการทำงาน
    }

    // สร้าง repository, service และ handler
    repo := user.NewRepository(db)      // สร้าง repository ใหม่โดยใช้ db ที่เชื่อมต่อ
    service := user.NewService(repo)    // สร้าง service ใหม่โดยใช้ repository ที่สร้างขึ้น
    handler := user.NewHandler(service) // สร้าง handler ใหม่โดยใช้ service ที่สร้างขึ้น

    // สร้าง Fiber app
    app := fiber.New() // สร้าง instance ใหม่ของ Fiber app

    // ใช้ middleware logging
    app.Use(func(c *fiber.Ctx) error {
        log.Printf("Received request: %s %s", c.Method(), c.Path()) // บันทึกข้อมูล request ที่ได้รับ
        return c.Next() // ดำเนินการ request ต่อไป
    })

    // ลงทะเบียน routes
    handler.RegisterRoutes(app) // เรียกใช้ method RegisterRoutes เพื่อกำหนดเส้นทางของ API

    // เริ่มเซิร์ฟเวอร์
    log.Fatal(app.Listen(":8080")) // เริ่มเซิร์ฟเวอร์และฟังการเชื่อมต่อที่พอร์ต 8080, บันทึก log ข้อผิดพลาดถ้าไม่สำเร็จ
}
