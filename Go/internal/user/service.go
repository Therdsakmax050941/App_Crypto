package user

import "myapp/pkg/models"

// Service interface กำหนด method สำหรับการจัดการข้อมูลผู้ใช้
type Service interface {
    GetUserByID(id int) (*models.User, error)  // Method สำหรับดึงข้อมูลผู้ใช้ตาม ID
    CreateUser(user *models.User) error        // Method สำหรับสร้างผู้ใช้ใหม่
    GetAllUsers() ([]*models.User, error)      // Method สำหรับดึงข้อมูลผู้ใช้ทั้งหมด
    Login(username, password string) (*models.User, error)  // Method สำหรับการ login
}

// service struct เก็บข้อมูล repository ที่ใช้งาน
type service struct {
    repo Repository  // Field สำหรับเก็บ repository
}

// NewService เป็นฟังก์ชันสำหรับสร้าง service ใหม่
func NewService(repo Repository) Service {
    return &service{repo}  // คืนค่า service ใหม่ที่เชื่อมต่อกับ repository
}

// GetUserByID ดึงข้อมูลผู้ใช้จาก repository ตาม ID
func (s *service) GetUserByID(id int) (*models.User, error) {
    return s.repo.FindByID(id)  // เรียกใช้ method FindByID ของ repository
}

// CreateUser สร้างผู้ใช้ใหม่ใน repository
func (s *service) CreateUser(user *models.User) error {
    return s.repo.Create(user)  // เรียกใช้ method Create ของ repository
}

// GetAllUsers ดึงข้อมูลผู้ใช้ทั้งหมดจาก repository
func (s *service) GetAllUsers() ([]*models.User, error) {
    return s.repo.FindAll()  // เรียกใช้ method FindAll ของ repository
}

// Login ตรวจสอบการเข้าสู่ระบบ
func (s *service) Login(username, password string) (*models.User, error) {
    return s.repo.FindByUsernameAndPassword(username, password)  // เรียกใช้ method FindByUsernameAndPassword ของ repository
}
