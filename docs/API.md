# WhoKnows API Documentation

## Base URL
```
http://localhost:3000
```

## Authentication
The API uses session-based authentication with cookies. Most endpoints require authentication.

## API Endpoints

### User Management

#### Register User
```http
POST /api/register
Content-Type: application/x-www-form-urlencoded
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| username | string | Yes | Username (3-50 characters) |
| email | string | Yes | Valid email address |
| password | string | Yes | Password (minimum 8 characters) |
| password_confirmation | string | Yes | Must match password |

**Response:**
```http
302 Found
Location: /register
Set-Cookie: _openapi_session=...
```

**Success:**
- Flash message: "Registration successful. You can now log in."

**Error:**
- Flash message with validation errors

---

#### Login
```http
POST /api/login
Content-Type: application/x-www-form-urlencoded
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| username | string | Yes | Registered username |
| password | string | Yes | User password |

**Response:**
```http
302 Found
Location: / (or /change_password if forced reset)
Set-Cookie: _openapi_session=...
```

**Success:**
- Redirects to home page
- Increments `user_logins_total{status="success"}` metric
- Updates user's `last_login` timestamp

**Error:**
- Redirects to login page
- Flash message: "Wrong username or password"
- Increments `user_logins_total{status="failure"}` metric

---

#### Logout
```http
GET /logout
POST /api/logout
```

**Response (HTML):**
```http
302 Found
Location: /login
```

**Response (JSON):**
```json
{
  "message": "Logged out successfully"
}
```

---

### Search

#### Search Pages
```http
GET /api/search?q=query
Accept: application/json
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| q | string | No | Search query (empty returns all pages) |

**Response:**
```json
{
  "data": [
    {
      "title": "Page Title",
      "url": "https://example.com/page",
      "content": "First 150 characters of content..."
    }
  ],
  "count": 10
}
```

**Behavior:**
- Searches both title and content fields
- Case-insensitive search
- Supports multi-term queries (AND logic)
- Limited to 100 results maximum
- Logs search query for analytics
- Increments `search_requests_total` metric

**Example:**
```bash
curl "http://localhost:3000/api/search?q=ruby+rails" \
  -H "Accept: application/json" \
  --cookie "session_cookie"
```

---

### Weather

#### Get Weather
```http
GET /api/weather?city=Copenhagen
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| city | string | No | City name (default: Copenhagen) |

**Response (Success):**
```json
{
  "city": "Copenhagen",
  "temperature": 15.5,
  "condition": "clear sky",
  "coord": {
    "lon": 12.5683,
    "lat": 55.6759
  }
}
```

**Response (Error):**
```json
{
  "error": "Unable to fetch weather for InvalidCity"
}
```

**Behavior:**
- Calls OpenWeatherMap API
- Logs search to `weather_searches` table
- Increments `weather_requests_total` metric
- Uses metric units (Celsius)

**Example:**
```bash
curl "http://localhost:3000/api/weather?city=London"
```

---

### Password Management

#### Change Password (UI)
```http
GET /change_password
```

**Authentication:** Required (session)

**Response:**
- Returns password change form
- Redirects to login if not authenticated

---

#### Update Password
```http
PATCH /change_password
Content-Type: application/x-www-form-urlencoded
```

**Authentication:** Required (session)

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| user[password] | string | Yes | New password (minimum 8 characters) |
| user[password_confirmation] | string | Yes | Must match password |

**Response:**
```http
200 OK
```

**Success:**
- Flash message: "Password changed successfully."
- Increments `password_changes_total{status="success"}` metric
- Clears `force_password_reset` flag

**Error:**
- Flash message: "Something went wrong. Please check the form."
- Increments `password_changes_total{status="failure"}` metric

---

## Metrics Endpoint

#### Prometheus Metrics
```http
GET /metrics
Accept: text/plain
```

**Authentication:** None required

**Response:**
```
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",path="/",status="200"} 1523.0

# HELP user_logins_total Total user login attempts
# TYPE user_logins_total counter
user_logins_total{status="success"} 342.0
user_logins_total{status="failure"} 28.0

# HELP search_requests_total Total search requests
# TYPE search_requests_total counter
search_requests_total 1823.0

# HELP weather_requests_total Total weather API requests
# TYPE weather_requests_total counter
weather_requests_total 456.0

# HELP password_changes_total Total password change attempts
# TYPE password_changes_total counter
password_changes_total{status="success"} 12.0
password_changes_total{status="failure"} 3.0
```

---

## Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 302 | Redirect (common for form submissions) |
| 401 | Unauthorized (not logged in) |
| 404 | Not Found |
| 422 | Unprocessable Entity (validation errors) |
| 500 | Internal Server Error |

---

## Rate Limiting
Currently not implemented. Consider implementing rate limiting for production:
- Login attempts: 5 per minute per IP
- Search requests: 100 per minute per user
- Weather API: 20 per minute per user

---

## Security Considerations

### HTTPS
- Production environment forces SSL
- All cookies are marked `secure` in production

### CSRF Protection
- All POST/PATCH/DELETE requests require CSRF token
- API endpoints skip CSRF verification (use with caution)

### Session Management
- Sessions expire after 24 hours
- Sessions use httponly cookies
- Sessions use SameSite=Lax for CSRF protection

### Password Requirements
- Minimum 8 characters
- Hashed using bcrypt
- Password confirmation required

---

## Examples

### Complete Registration Flow
```bash
# 1. Register
curl -X POST http://localhost:3000/api/register \
  -d "username=johndoe" \
  -d "email=john@example.com" \
  -d "password=SecurePass123" \
  -d "password_confirmation=SecurePass123" \
  -c cookies.txt

# 2. Login
curl -X POST http://localhost:3000/api/login \
  -d "username=johndoe" \
  -d "password=SecurePass123" \
  -c cookies.txt \
  -b cookies.txt

# 3. Search
curl "http://localhost:3000/api/search?q=ruby" \
  -H "Accept: application/json" \
  -b cookies.txt

# 4. Logout
curl -X POST http://localhost:3000/api/logout \
  -H "Accept: application/json" \
  -b cookies.txt
```

---

## Testing

### Test Environment
Use the test-specific endpoints with `/test` prefix for integration testing:
- `POST /test/register` - Test user registration
- `POST /test/login` - Test user login
- `GET /test/logout` - Test user logout

### RSpec Tests
```bash
bundle exec rspec
```

---

## Support
For issues or questions, please refer to:
- GitHub Issues: https://github.com/devkopa/WhoKnows-next-gen/issues
- Documentation: ./docs/
- README: ./README.md
