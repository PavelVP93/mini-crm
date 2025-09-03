import API from './api'

export const USE_API = true

const LS_KEYS = {
  products: 'fishing_products',
  customers: 'fishing_customers',
  orders: 'fishing_orders',
  reservations: 'fishing_reservations'
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

function makeStore(api: any, key: string) {
  return {
    async get<T>() {
      if (USE_API) return api.list<T>()
      return readLS<T[]>(key, [])
    },
    async save<T>(item: T) {
      if (USE_API) return api.create<T>(item)
      const items = readLS<T[]>(key, [])
      items.push(item)
      writeLS(key, items)
      return item
    },
    async update<T extends { id: string | number }>(id: string | number, patch: Partial<T>) {
      if (USE_API) return api.update<T>(id, patch)
      const items = readLS<T[]>(key, [])
      const idx = items.findIndex((it: any) => it.id === id)
      if (idx >= 0) {
        const updated = { ...items[idx], ...patch }
        items[idx] = updated
        writeLS(key, items)
        return updated
      }
      return null
    }
  }
}

const Store = {
  products: makeStore(new API.Products(), LS_KEYS.products),
  customers: makeStore(new API.Customers(), LS_KEYS.customers),
  orders: makeStore(new API.Orders(), LS_KEYS.orders),
  reservations: makeStore(new API.Reservations(), LS_KEYS.reservations)
}

export default Store
