# mini-crm

## Configuration

Create a `.env.local` file and set the backend API base URL with the `NEXT_PUBLIC_API_URL` environment variable. This value is used by the login page to send requests to the backend.

Example `.env.local`:

```
NEXT_PUBLIC_API_URL=http://localhost:3000/backend
```

### Authentication setup

The frontend sends a `POST` request to `${NEXT_PUBLIC_API_URL}/login` and includes cookies via `credentials: 'include'`. Ensure the backend responds with JSON and sets an authentication cookie (for example, a session or JWT cookie). If the backend is hosted on a different domain, configure CORS to allow credentials.

## Development

Install dependencies and start the development server:

```
npm install
npm run dev
```
