# 🛒 Product Service (Ecommerce Microservices)

The **Product Service** is a core microservice in my Ecommerce system.  
It handles product creation, updating, deletion, filtering, and retrieval.  
Built using **Spring Boot**, connected via **API Gateway**, and discoverable through **Eureka Service Registry**.

---

##  Tech Stack
- **Spring Boot**
- **Spring Data JPA**
- **MySQL**
- **Spring Cloud Netflix Eureka**
- **Lombok**
- **Spring Web**
- **API Gateway Integration**
- **Maven**

---

## 📌 Features
- Add new products  
- Update product details  
- Get product by ID  
- Get all products  
- Delete product  
- Category-based filtering  
- Integrated with API Gateway  
- Registered with Eureka server  

---

## 🧩 Microservice Architecture (High-level)

Client → API Gateway → Product Service → Database
→ Order Service
→ Payment Service
→ OTP Service

---

## 📁 Project Structure

src/
├── main/
│ ├── java/com/yourname/productservice
│ │ ├── controller
│ │ ├── service
│ │ ├── repository
│ │ ├── entity/model
│ │ └── exception
│ └── resources
│ ├── application.properties
│ └── schema.sql (optional)

---


# 📚 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| **POST** | `/Create` | Create a new product |
| **GET** | `/{name}` | Get product by its name |
| **GET** | `/category/{category}` | Get all products by category |
| **GET** | `/c/{id}` | Get product by ID |
| **GET** | `/products/by-ids?ids=1,2,3` | Get multiple products by list of IDs |
| **GET** | `/all` | Get all products |
| **PUT** | `/{id}` | Update a product by ID |
| **DELETE** | `/{id}` | Delete a product by ID |
| **GET** | `/belowPricePaginated?price=&page=&size=` | Get products below price **with pagination** |
| **GET** | `/BetweenPricePaginated?maxprice=&minprice=&page=&size=` | Get products between min–max price **with pagination** |


---

# 🔎 **Endpoint Details**

### ✅ **1. Create Product**
POST /Product/Create
Body: ProductDto

---

### ✅ **2. Get Product by Name**
GET /Product/{name}

---

### ✅ **3. Get Products by Category**

---

### ✅ **4. Get Product by ID**

---

### ✅ **5. Get Products by Multiple IDs**
GET /Product/products/by-ids?ids=1,2,3,4

---

### ✅ **6. Get All Products**

---

### ✅ **7. Update Product**

PUT /Product/{id}
Body: ProductDto

---

### ✅ **8. Delete Product**
DELETE /Product/{id}

---

### ✅ **9. Get Products Below Price (Paginated)**
GET /Product/belowPricePaginated?price=1000&page=0&size=10

---

### ✅ **10. Get Products Between Min–Max Price (Paginated)**
GET /Product/BetweenPricePaginated?maxprice=5000&minprice=2000&page=0&size=10

---

# 📁 Project Structure

---


# 🧪 Testing Tools
- Postman  
- Thunder Client  

---

# 👤 Author
**Pranav Sharma**  
Microservices | Spring Boot | Kafka | Redis | SQL









