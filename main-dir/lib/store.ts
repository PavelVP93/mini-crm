import API from './api'
import type { Customer } from './types'

export const USE_API = true

const LS_KEYS = {
  products: 'fishing_products',
  customers: 'fishing_customers',
  orders: 'fishing_orders',
  reservations: 'fishing_reservations',
  settings: 'fishing_settings'
} as const

function readLS<T>(key: string, fallback: T): T {
  if (typeof localStorage === 'undefined') return fallback
  try {
    const v = JSON.parse(localStorage.getItem(key) || 'null')
    return (v ?? fallback) as T
  } catch {
    return fallback
  }
}

function writeLS<T>(key: string, value: T) {
  if (typeof localStorage === 'undefined') return
  localStorage.setItem(key, JSON.stringify(value))
}

function makeStore<T extends { id: string | number } = any>(api: any, key: string) {
  return {
    async get() {
      if (USE_API) return api.list() as Promise<T[]>
      return readLS<T[]>(key, [])
    },
    async save(item: T) {
      if (USE_API) return api.create(item) as Promise<T>
      const items = readLS<T[]>(key, [])
      items.push(item)
      writeLS(key, items)
      return item
    },
    async saveAll(items: T[]) {
      if (USE_API) return
      writeLS(key, items)
    },
    async update(id: string | number, patch: Partial<T>) {
      if (USE_API) return api.update(id, patch) as Promise<T>
      const items = readLS<T[]>(key, [])
      const idx = items.findIndex((it: any) => it.id === id)
      if (idx >= 0) {
        const updated = { ...items[idx], ...patch }
        items[idx] = updated
        writeLS(key, items)
        return updated
      }
      return null
    },
    async delete(id: string | number) {
      if (USE_API) return api.delete(id)
      const items = readLS<any[]>(key, [])
      const filtered = items.filter((it: any) => it.id !== id)
      writeLS(key, filtered)
    }
  }
}

const Store = {
  products: makeStore(new API.Products(), LS_KEYS.products),
  customers: makeStore<Customer>(new API.Customers(), LS_KEYS.customers),
  orders: makeStore(new API.Orders(), LS_KEYS.orders),
  reservations: makeStore(new API.Reservations(), LS_KEYS.reservations),
  async getReservations() {
    return this.reservations.get()
  },
  settings: {
    async get<T>(fallback: T) {
      return readLS<T>(LS_KEYS.settings, fallback)
    },
    async save<T>(value: T) {
      writeLS(LS_KEYS.settings, value)
      return value
    }
  }
}

export default Store
