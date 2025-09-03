const BASE_URL = (process.env.NEXT_PUBLIC_API_BASE ?? '').replace(/\/$/, '')

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  try {
    const res = await fetch(`${BASE_URL}/${path.replace(/^\//, '')}`, {
      headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
      ...options
    })

    const text = await res.text()
    let data: any = null
    if (text) {
      try {
        data = JSON.parse(text)
      } catch {
        throw new Error('Invalid JSON response')
      }
    }

    if (!res.ok) {
      throw new Error((data && data.message) || res.statusText)
    }

    return data as T
  } catch (err) {
    if (err instanceof Error) {
      throw err
    }
    throw new Error('Unknown error')
  }
}

class Resource {
  constructor(private path: string) {}

  list<T>() {
    return request<T>(this.path)
  }

  create<T>(payload: unknown) {
    return request<T>(this.path, {
      method: 'POST',
      body: JSON.stringify(payload)
    })
  }

  update<T>(id: string | number, payload: unknown) {
    return request<T>(`${this.path}/${id}`, {
      method: 'PUT',
      body: JSON.stringify(payload)
    })
  }

  delete<T>(id: string | number) {
    return request<T>(`${this.path}/${id}`, { method: 'DELETE' })
  }
}

export class Products extends Resource {
  constructor() {
    super('products')
  }
}

export class Customers extends Resource {
  constructor() {
    super('customers')
  }
}

export class Orders extends Resource {
  constructor() {
    super('orders')
  }
}

export class Reservations extends Resource {
  constructor() {
    super('reservations')
  }
}

export default { Products, Customers, Orders, Reservations }
