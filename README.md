# mini-crm

## Configuration

Create a `.env.local` file and set the backend API base URL with the `NEXT_PUBLIC_API_URL` environment variable. This value is used by the login page to send requests to the backend.

Example `.env.local`:

```
NEXT_PUBLIC_API_URL=http://localhost:3000/backend
```

### Authentication setup

The frontend sends a `POST` request to `${NEXT_PUBLIC_API_URL}/login` and includes cookies via `credentials: 'include'`. Ensure the backend responds with JSON and sets an authentication cookie (for example, a session or JWT cookie). If the backend is hosted on a different domain, configure CORS to allow credentials.

### Example user

To create an initial admin account, insert a user with a hashed password:

```
INSERT INTO users (id, fullName, email, passwordHash)
VALUES ('u_admin', 'Admin', 'admin@example.com', '$2y$12$0hkC8N2T03fA/GJ5zFLAyuAuhfIru8jd9A1EbdDR4O6WEp5Xo.lwG');
```

The hash above was generated using PHP's `password_hash('adminpass', PASSWORD_DEFAULT)`.

## Development

Install dependencies and start the development server:

```
npm install
npm run dev
```
