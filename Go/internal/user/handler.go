package user

import (
    "github.com/golang-jwt/jwt"
    "github.com/gofiber/fiber/v2"
    "myapp/pkg/models"
    "strconv"
    "time"
)

var jwtSecretKey = []byte("your_secret_key") // ใช้เพื่อเซ็น JWT Token

// Handler interface กำหนด method สำหรับการจัดการ route
type Handler interface {
    RegisterRoutes(app *fiber.App)  // Method สำหรับลงทะเบียน route
}

// handler struct เก็บข้อมูล service ที่ใช้งาน
type handler struct {
    service Service  // Field สำหรับเก็บ service
}

// NewHandler เป็นฟังก์ชันสำหรับสร้าง handler ใหม่
func NewHandler(service Service) Handler {
    return &handler{service}  // คืนค่า handler ใหม่ที่เชื่อมต่อกับ service
}

// RegisterRoutes ลงทะเบียน route ต่าง ๆ
func (h *handler) RegisterRoutes(app *fiber.App) {
    app.Use("/protected", AuthMiddleware) // ใช้ AuthMiddleware สำหรับ route ที่ต้องการการตรวจสอบ Token
    app.Get("/users/:id", h.GetUserByID)       // Route สำหรับดึงข้อมูลผู้ใช้ตาม ID
    app.Post("/CreateUser", h.CreateUser)      // Route สำหรับสร้างผู้ใช้ใหม่
    app.Get("/users", h.GetAllUsers)           // Route สำหรับดึงข้อมูลผู้ใช้ทั้งหมด
    app.Post("/login", h.Login)                // Route สำหรับการ login
}

// generateJWT สร้าง JWT Token สำหรับผู้ใช้
func generateJWT(userID int) (string, error) {
    token := jwt.New(jwt.SigningMethodHS256)

    claims := token.Claims.(jwt.MapClaims)
    claims["user_id"] = userID
    claims["exp"] = time.Now().Add(time.Hour * 24).Unix()

    tokenString, err := token.SignedString(jwtSecretKey)
    if err != nil {
        return "", err
    }

    return tokenString, nil
}

// AuthMiddleware ตรวจสอบ JWT Token
func AuthMiddleware(c *fiber.Ctx) error {
    tokenString := c.Get("Authorization")

    if tokenString == "" {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
            "error": "Token is required",
        })
    }

    token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
        return jwtSecretKey, nil
    })

    if err != nil || !token.Valid {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
            "error": "Invalid or expired token",
        })
    }

    return c.Next()
}

// GetUserByID ดึงข้อมูลผู้ใช้จาก service ตาม ID
func (h *handler) GetUserByID(c *fiber.Ctx) error {
    id, err := strconv.Atoi(c.Params("id"))  // แปลงค่า ID จาก string เป็น int
    if err != nil {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "error":   "Invalid user ID format",
            "message": err.Error(),
        })  // คืนค่า error ถ้า ID ไม่ถูกต้อง
    }
    user, err := h.service.GetUserByID(id)  // เรียกใช้ method GetUserByID ของ service
    if err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error":   "Error fetching user",
            "message": err.Error(),
        })  // คืนค่า error ถ้าเกิดข้อผิดพลาด
    }
    if user == nil {
        return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
            "error": "User not found",
        })  // คืนค่า error ถ้าไม่พบผู้ใช้
    }
    return c.JSON(user)  // คืนค่าข้อมูลผู้ใช้ในรูปแบบ JSON
}

// CreateUser สร้างผู้ใช้ใหม่ใน service
func (h *handler) CreateUser(c *fiber.Ctx) error {
    var req models.CreateUserRequest  // สร้างตัวแปรสำหรับเก็บข้อมูล request
    if err := c.BodyParser(&req); err != nil {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "error":   "Invalid request payload",
            "message": err.Error(),
        })  // คืนค่า error ถ้าข้อมูล request ไม่ถูกต้อง
    }
    
    // แปลง CreateUserRequest เป็น User
    user := &models.User{
        Username: req.Username,
        Password: req.Password,
    }
    
    if err := h.service.CreateUser(user); err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error":   "Error creating user",
            "message": err.Error(),
        })  // คืนค่า error ถ้าเกิดข้อผิดพลาดในการสร้างผู้ใช้
    }
    return c.Status(fiber.StatusCreated).JSON(user)  // คืนค่าผู้ใช้ที่สร้างใหม่ในรูปแบบ JSON
}

// GetAllUsers ดึงข้อมูลผู้ใช้ทั้งหมดจาก service
func (h *handler) GetAllUsers(c *fiber.Ctx) error {
    users, err := h.service.GetAllUsers()  // เรียกใช้ method GetAllUsers ของ service
    if err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error":   "Error fetching users",
            "message": err.Error(),
        })  // คืนค่า error ถ้าเกิดข้อผิดพลาด
    }
    return c.JSON(users)  // คืนค่าข้อมูลผู้ใช้ทั้งหมดในรูปแบบ JSON
}

// Login ตรวจสอบการเข้าสู่ระบบ
func (h *handler) Login(c *fiber.Ctx) error {
    var req models.LoginRequest
    if err := c.BodyParser(&req); err != nil {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "error": "Invalid request payload",
            "message": err.Error(),
        })
    }

    user, err := h.service.Login(req.Username, req.Password)
    if err != nil {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
            "error": "Invalid username or password",
            "message": err.Error(),
        })
    }

    if user == nil {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
            "error": "User not found",
        })
    }

    token, err := generateJWT(user.ID)
    if err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error": "Error generating token",
            "message": err.Error(),
        })
    }

    return c.JSON(fiber.Map{
        "token": token,
    })
}
