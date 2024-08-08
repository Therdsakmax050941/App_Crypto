package user

import (
    "database/sql"
    "myapp/pkg/models"
)

// Repository interface กำหนด method สำหรับการทำงานกับฐานข้อมูลผู้ใช้
type Repository interface {
    FindByID(id int) (*models.User, error)    // Method สำหรับค้นหาผู้ใช้ตาม ID
    Create(user *models.User) error           // Method สำหรับสร้างผู้ใช้ใหม่
    FindAll() ([]*models.User, error)         // Method สำหรับดึงข้อมูลผู้ใช้ทั้งหมด
    FindByUsernameAndPassword(username, password string) (*models.User, error)  // Method สำหรับการ login
}

// repository struct เก็บข้อมูลการเชื่อมต่อกับฐานข้อมูล
type repository struct {
    db *sql.DB  // Field สำหรับเก็บการเชื่อมต่อฐานข้อมูล
}

// NewRepository เป็นฟังก์ชันสำหรับสร้าง repository ใหม่
func NewRepository(db *sql.DB) Repository {
    return &repository{db}  // คืนค่า repository ใหม่ที่เชื่อมต่อกับฐานข้อมูล
}

// FindByID ค้นหาผู้ใช้ในฐานข้อมูลตาม ID
func (r *repository) FindByID(id int) (*models.User, error) {
    var user models.User  // สร้างตัวแปร user สำหรับเก็บข้อมูลผู้ใช้
    row := r.db.QueryRow("SELECT id, username, password FROM users WHERE id = ?", id)  // Query ค้นหาผู้ใช้ตาม ID
    err := row.Scan(&user.ID, &user.Username, &user.Password)  // สแกนผลลัพธ์จาก query ไปที่ตัวแปร user
    if err == sql.ErrNoRows {
        return nil, nil  // ถ้าไม่พบผู้ใช้ คืนค่า nil
    }
    if err != nil {
        return nil, err  // ถ้าเกิดข้อผิดพลาดอื่น ๆ คืนค่า error
    }
    return &user, nil  // คืนค่าผู้ใช้ที่พบ
}

// Create สร้างผู้ใช้ใหม่ในฐานข้อมูล
func (r *repository) Create(user *models.User) error {
    result, err := r.db.Exec("INSERT INTO users (username, password) VALUES (?, ?)", user.Username, user.Password)  // สร้างผู้ใช้ใหม่
    if err != nil {
        return err  // ถ้าเกิดข้อผิดพลาด คืนค่า error
    }
    id, err := result.LastInsertId()  // ดึง ID ที่สร้างใหม่
    if err != nil {
        return err  // ถ้าเกิดข้อผิดพลาดในการดึง ID คืนค่า error
    }
    user.ID = int(id)  // กำหนด ID ให้กับผู้ใช้
    return nil  // คืนค่า nil ถ้าสำเร็จ
}

// FindAll ดึงข้อมูลผู้ใช้ทั้งหมดจากฐานข้อมูล
func (r *repository) FindAll() ([]*models.User, error) {
    rows, err := r.db.Query("SELECT id, username, password FROM users")  // Query ดึงข้อมูลผู้ใช้ทั้งหมด
    if err != nil {
        return nil, err  // ถ้าเกิดข้อผิดพลาด คืนค่า error
    }
    defer rows.Close()  // ปิดผลลัพธ์เมื่อเสร็จสิ้นการใช้งาน

    var users []*models.User  // สร้าง slice สำหรับเก็บข้อมูลผู้ใช้
    for rows.Next() {  // วนลูปในผลลัพธ์
        var user models.User  // สร้างตัวแปร user สำหรับเก็บข้อมูลผู้ใช้
        if err := rows.Scan(&user.ID, &user.Username, &user.Password); err != nil {
            return nil, err  // ถ้าเกิดข้อผิดพลาดในการสแกนผลลัพธ์ คืนค่า error
        }
        users = append(users, &user)  // เพิ่มผู้ใช้ใน slice
    }
    return users, nil  // คืนค่าข้อมูลผู้ใช้ทั้งหมด
}

// FindByUsernameAndPassword ค้นหาผู้ใช้ในฐานข้อมูลตาม username และ password
func (r *repository) FindByUsernameAndPassword(username, password string) (*models.User, error) {
    var user models.User  // สร้างตัวแปร user สำหรับเก็บข้อมูลผู้ใช้
    row := r.db.QueryRow("SELECT id, username, password FROM users WHERE username = ? AND password = ?", username, password)  // Query ค้นหาผู้ใช้ตาม username และ password
    err := row.Scan(&user.ID, &user.Username, &user.Password)  // สแกนผลลัพธ์จาก query ไปที่ตัวแปร user
    if err == sql.ErrNoRows {
        return nil, nil  // ถ้าไม่พบผู้ใช้ คืนค่า nil
    }
    if err != nil {
        return nil, err  // ถ้าเกิดข้อผิดพลาดอื่น ๆ คืนค่า error
    }
    return &user, nil  // คืนค่าผู้ใช้ที่พบ
}
