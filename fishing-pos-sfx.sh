#!/usr/bin/env bash
# fishing-pos-sfx.sh
# Самораспаковывающийся инсталлятор демо-проекта Fishing POS (Next.js + Tailwind + shadcn/ui)
# Делает: создаёт проект, ставит зависимости, добавляет UI-компоненты, пишет ПОЛНЫЙ UI в app/page.tsx,
# билдит (Next 14 с output:'export' сам положит статику в out/), пакует out/ в site.zip и кладёт installer.php.
# Требования: Node.js 18+ (подойдёт 20.x), npm, интернет, утилита zip (для упаковки).

set -euo pipefail

APP_DIR="${1:-fishing-pos}"

echo "==> Creating project at $APP_DIR"
mkdir -p "$APP_DIR/app"
mkdir -p "$APP_DIR/components/ui"
mkdir -p "$APP_DIR/public"

# ----------------------------
# package.json
# ----------------------------
cat > "$APP_DIR/package.json" <<'JSON'
{
  "name": "fishing-pos",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "class-variance-authority": "^0.7.0",
    "lucide-react": "^0.453.0",
    "next": "14.2.4",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "recharts": "^2.12.7",
    "tailwind-merge": "^2.5.2"
  },
  "devDependencies": {
    "@types/node": "^20.11.30",
    "@types/react": "^18.3.3",
    "autoprefixer": "^10.4.18",
    "postcss": "^8.4.38",
    "tailwindcss": "^3.4.4",
    "typescript": "^5.4.5"
  }
}
JSON

# ----------------------------
# tsconfig.json
# ----------------------------
cat > "$APP_DIR/tsconfig.json" <<'JSON'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": false,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "baseUrl": ".",
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", ".next/types/**/*.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
JSON

# ----------------------------
# next.config.js
# ----------------------------
cat > "$APP_DIR/next.config.js" <<'JS'
/** @type {import('next').NextConfig} */
const nextConfig = { output: 'export', images: { unoptimized: true } };
module.exports = nextConfig;
JS

# ----------------------------
# postcss.config.js
# ----------------------------
cat > "$APP_DIR/postcss.config.js" <<'JS'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
JS

# ----------------------------
# tailwind.config.js
# ----------------------------
cat > "$APP_DIR/tailwind.config.js" <<'JS'
/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}"
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
JS

# ----------------------------
# app/layout.tsx
# ----------------------------
cat > "$APP_DIR/app/layout.tsx" <<'TSX'
export const metadata = { title: "Fishing POS — MVP" };
import "./globals.css";
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ru">
      <body>{children}</body>
    </html>
  );
}
TSX

# ----------------------------
# app/globals.css
# ----------------------------
cat > "$APP_DIR/app/globals.css" <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root { color-scheme: light; }

body { @apply bg-white text-slate-900; }
CSS

# ----------------------------
# app/page.tsx — ПОЛНЫЙ ИНТЕРФЕЙС (с фиксом Select через sentinel __NONE__)
# ----------------------------
cat > "$APP_DIR/app/page.tsx" <<'TSX'
'use client';
import React, { useEffect, useMemo, useState } from "react";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Card, CardHeader, CardTitle, CardContent, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from "@/components/ui/table";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { ScrollArea } from "@/components/ui/scroll-area";
import { ShoppingCart, Scale, Calendar as CalendarIcon, Users, BarChart2, Settings, Trash2, Plus, Minus, CreditCard, Wallet } from "lucide-react";
import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, Tooltip, Legend, BarChart, Bar } from "recharts";

// ---------- Helpers / constants ----------
const NONE = "__NONE__"; // sentinel for empty Select choice (valid non-empty string)

const currency = (n:number) => new Intl.NumberFormat("ru-RU", { style: "currency", currency: "RUB", maximumFractionDigits: 2 }).format(n || 0);
const kg = (n:number) => `${(n ?? 0).toFixed(2)} кг`;
const rand = (min:number, max:number) => Math.random() * (max - min) + min;
const todayISO = () => new Date().toISOString().slice(0, 10);

const LS = {
  products: "fishing_products",
  customers: "fishing_customers",
  orders: "fishing_orders",
  reservations: "fishing_reservations",
  settings: "fishing_settings",
} as const;

function loadLS<T>(key: string, fallback: T): T {
  try { const v = JSON.parse(localStorage.getItem(key) || "null"); return (v ?? fallback) as T; } catch { return fallback; }
}
function saveLS<T>(key: string, value: T) { localStorage.setItem(key, JSON.stringify(value)); }

// ---------- Mock data ----------
const DEFAULT_PRODUCTS = [
  { id: "p1", name: "Форель радужная", type: "GOOD", unit: "KG", isWeightable: true, price: 850, group: "Рыба", isActive: true },
  { id: "p2", name: "Карп зеркальный", type: "GOOD", unit: "KG", isWeightable: true, price: 380, group: "Рыба", isActive: true },
  { id: "p3", name: "Сом", type: "GOOD", unit: "KG", isWeightable: true, price: 620, group: "Рыба", isActive: true },
  { id: "p4", name: "Входной билет", type: "SERVICE", unit: "PIECE", isWeightable: false, price: 400, group: "Вход", isActive: true },
  { id: "p5", name: "Аренда беседки (час)", type: "SERVICE", unit: "HOUR", isWeightable: false, price: 500, group: "Беседки", isActive: true },
  { id: "p6", name: "Мангал", type: "SERVICE", unit: "PIECE", isWeightable: false, price: 300, group: "Допы", isActive: true },
  { id: "p7", name: "Уголь (3 кг)", type: "GOOD", unit: "PIECE", isWeightable: false, price: 260, group: "Допы", isActive: true },
];

const DEFAULT_CUSTOMERS = [
  { id: "c1", fullName: "Иван Петров", phone: "+7 900 000-00-01", tier: "Bronze", points: 120 },
  { id: "c2", fullName: "Анна Сидорова", phone: "+7 900 000-00-02", tier: "Silver", points: 820 },
];

const DEFAULT_GAZEBOS = [
  { id: "g1", name: "Беседка №1", capacity: 6, isActive: true },
  { id: "g2", name: "Беседка №2", capacity: 8, isActive: true },
  { id: "g3", name: "Беседка №3", capacity: 12, isActive: true },
  { id: "g4", name: "Беседка №4", capacity: 10, isActive: true },
  { id: "g5", name: "Беседка №5", capacity: 6, isActive: true },
];

const DEFAULT_SETTINGS = {
  weight: { rounding: 0.01, simulateScale: true, port: "COM1", protocol: "AUTODETECT" },
  loyalty: { earnRate: 0.05, redeemRate: 1, minOrderForEarn: 300, tiers: { Bronze: 0, Silver: 10000, Gold: 30000 } },
};

// ---------- App ----------
export default function App() {
  const [products, setProducts] = useState(DEFAULT_PRODUCTS);
  const [customers, setCustomers] = useState(DEFAULT_CUSTOMERS);
  const [orders, setOrders] = useState<any[]>([]);
  const [reservations, setReservations] = useState<any[]>([]);
  const [settings, setSettings] = useState(DEFAULT_SETTINGS);
  const [tab, setTab] = useState("pos");

  useEffect(() => {
    setProducts(loadLS(LS.products, DEFAULT_PRODUCTS));
    setCustomers(loadLS(LS.customers, DEFAULT_CUSTOMERS));
    setOrders(loadLS(LS.orders, []));
    setReservations(loadLS(LS.reservations, []));
    setSettings(loadLS(LS.settings, DEFAULT_SETTINGS));
  }, []);

  useEffect(() => saveLS(LS.products, products), [products]);
  useEffect(() => saveLS(LS.customers, customers), [customers]);
  useEffect(() => saveLS(LS.orders, orders), [orders]);
  useEffect(() => saveLS(LS.reservations, reservations), [reservations]);
  useEffect(() => saveLS(LS.settings, settings), [settings]);

  // Safety self-test for Select sentinel mapping
  useEffect(() => {
    console.assert(NONE !== "", "Sentinel NONE must not be empty");
    const mapToSelect = (v:any) => (v == null ? NONE : v);
    const mapFromSelect = (v:any) => (v === NONE ? null : v);
    console.assert(mapToSelect(null) === NONE && mapFromSelect(NONE) === null, "Select mapping for NONE works");
  }, []);

  return (
    <div className="p-4 md:p-6 space-y-4">
      <header className="flex items-center gap-3">
        <div className="text-2xl font-bold">🎣 Fishing POS — MVP</div>
        <Badge variant="secondary">RU</Badge>
        <div className="ml-auto text-sm text-muted-foreground">Локальные данные (localStorage)</div>
      </header>

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList className="grid grid-cols-5 w-full">
          <TabsTrigger value="pos" className="flex items-center gap-2"><ShoppingCart className="h-4 w-4"/>POS</TabsTrigger>
          <TabsTrigger value="reservations" className="flex items-center gap-2"><CalendarIcon className="h-4 w-4"/>Бронирования</TabsTrigger>
          <TabsTrigger value="crm" className="flex items-center gap-2"><Users className="h-4 w-4"/>CRM</TabsTrigger>
          <TabsTrigger value="reports" className="flex items-center gap-2"><BarChart2 className="h-4 w-4"/>Отчёты</TabsTrigger>
          <TabsTrigger value="admin" className="flex items-center gap-2"><Settings className="h-4 w-4"/>Админ</TabsTrigger>
        </TabsList>

        <TabsContent value="pos"><POS products={products} settings={settings} customers={customers} setCustomers={setCustomers} onPaid={(o:any)=>setOrders([o, ...orders])}/></TabsContent>
        <TabsContent value="reservations"><Reservations gazebos={DEFAULT_GAZEBOS} customers={customers} reservations={reservations} setReservations={setReservations} /></TabsContent>
        <TabsContent value="crm"><CRM customers={customers} setCustomers={setCustomers} orders={orders}/></TabsContent>
        <TabsContent value="reports"><Reports orders={orders} reservations={reservations} products={products}/></TabsContent>
        <TabsContent value="admin"><Admin products={products} setProducts={setProducts} settings={settings} setSettings={setSettings}/></TabsContent>
      </Tabs>
    </div>
  );
}

// ---------- POS ----------
function POS({ products, settings, customers, setCustomers, onPaid }:{
  products:any[], settings:any, customers:any[], setCustomers:any, onPaid:(o:any)=>void
}){
  const [search, setSearch] = useState("");
  const [cart, setCart] = useState<any[]>([]);
  const [connected, setConnected] = useState(settings.weight.simulateScale);
  const [liveWeight, setLiveWeight] = useState(0);
  const [discountPct, setDiscountPct] = useState(0);
  const [customerId, setCustomerId] = useState<string|null>(null);
  const [payOpen, setPayOpen] = useState(false);

  const toSelectVal = (cid:string|null) => (cid == null ? NONE : cid);
  const fromSelectVal = (v:string) => (v === NONE ? null : v);

  // Simulate scale
  useEffect(() => {
    if (!connected) return;
    const t = setInterval(() => {
      const base = Math.random() < 0.6 ? rand(0.9, 2.2) : 0; // 40% пусто
      const jitter = base === 0 ? 0 : rand(-0.02, 0.02);
      const v = Math.max(0, base + jitter);
      const rounding = settings.weight.rounding || 0.01;
      const rounded = Math.round(v / rounding) * rounding;
      setLiveWeight(Number(rounded.toFixed(2)));
    }, 800);
    return () => clearInterval(t);
  }, [connected, settings.weight.rounding]);

  const filtered = useMemo(
    () => products.filter(p => p.isActive && (p.name.toLowerCase().includes(search.toLowerCase()) || (p.group||"").toLowerCase().includes(search.toLowerCase()))),
    [products, search]
  );

  const totals = useMemo(() => {
    const sub = cart.reduce((s, it) => s + (it.total || 0), 0);
    const disc = sub * (discountPct/100);
    const grand = sub - disc;
    return { sub, disc, grand };
  }, [cart, discountPct]);

  function addProduct(p:any){
    if (p.isWeightable) {
      const weightKg = Math.max(liveWeight, 0);
      if (!weightKg) return; // требуем вес
      const total = p.price * weightKg;
      const item = { productId: p.id, name: p.name, unitPrice: p.price, qty: 1, weightKg, discountPct: 0, total };
      setCart([item, ...cart]);
    } else {
      const item = { productId: p.id, name: p.name, unitPrice: p.price, qty: 1, weightKg: null, discountPct: 0, total: p.price };
      setCart([item, ...cart]);
    }
  }

  function updateQty(idx:number, delta:number){
    setCart(cart.map((it, i) => {
      if (i !== idx) return it;
      const qty = Math.max(1, (it.qty || 1) + delta);
      const total = (it.weightKg ? (it.unitPrice * it.weightKg) : (it.unitPrice * qty));
      return { ...it, qty, total };
    }));
  }
  function removeItem(idx:number){ setCart(cart.filter((_, i) => i !== idx)); }

  function applyItemDiscount(idx:number, pct:number){
    setCart(cart.map((it, i) => i !== idx ? it : ({...it, discountPct: pct, total: (it.weightKg ? it.unitPrice * it.weightKg : it.unitPrice * it.qty) * (1 - pct/100)})));
  }

  function handlePaid(payments:any[]){
    const id = `o_${Date.now()}`;
    const number = `POS-${new Date().toISOString().slice(0,10).replaceAll('-','')}-${String(Math.floor(Math.random()*999)).padStart(3,'0')}`;
    const status = "PAID";
    const createdAt = new Date().toISOString();
    const paidAt = createdAt;
    const items = cart;
    const totalsFull = { ...totals };
    const custId = customerId;

    // Loyalty earn
    if (custId) {
      const earn = totalsFull.grand >= (settings.loyalty.minOrderForEarn||0) ? Math.floor(totalsFull.grand * (settings.loyalty.earnRate||0)) : 0;
      setCustomers((cs:any[]) => cs.map(c => c.id===custId ? { ...c, points: (c.points||0)+earn } : c));
    }

    const order = { id, number, items, payments, customerId: custId, status, createdAt, paidAt, totals: totalsFull };
    onPaid(order);
    setCart([]);
    setDiscountPct(0);
    setCustomerId(null);
  }

  const groups = Array.from(new Set(filtered.map((p:any)=>p.group))).filter(Boolean) as string[];

  return (
    <div className="grid md:grid-cols-3 gap-4">
      <div className="md:col-span-2 space-y-4">
        <Card>
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <Input placeholder="Поиск: товар/группа" value={search} onChange={(e)=>setSearch(e.target.value)} />
              <Badge>Активно: {filtered.length}</Badge>
            </div>
          </CardHeader>
          <CardContent>
            <ScrollArea className="h-[360px] pr-2">
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
                {groups.map(g => (
                  <div key={g} className="col-span-full text-xs uppercase text-muted-foreground mt-2">{g}</div>
                ))}
                {filtered.map((p:any) => (
                  <button key={p.id} onClick={()=>addProduct(p)} className="text-left p-3 rounded-2xl border hover:shadow transition flex flex-col gap-1">
                    <div className="font-medium leading-tight">{p.name}</div>
                    <div className="text-sm text-muted-foreground">{p.isWeightable ? `${currency(p.price)} / кг` : currency(p.price)}</div>
                    <div className="mt-auto flex items-center gap-2 text-xs">
                      {p.isWeightable && <Badge variant="outline" className="flex items-center gap-1"><Scale className="h-3 w-3"/>весовой</Badge>}
                      <Badge variant={p.type === "SERVICE" ? "secondary" : "outline"}>{p.type === "SERVICE" ? "услуга" : "товар"}</Badge>
                    </div>
                  </button>
                ))}
              </div>
            </ScrollArea>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2 flex flex-row items-center justify-between">
            <div className="flex items-center gap-2"><ShoppingCart className="h-5 w-5"/><CardTitle>Текущий чек</CardTitle></div>
            <div className="flex items-center gap-2">
              <Select value={toSelectVal(customerId)} onValueChange={(v)=>setCustomerId(fromSelectVal(v))}>
                <SelectTrigger className="w-[260px]"><SelectValue placeholder="Клиент (опц.)"/></SelectTrigger>
                <SelectContent>
                  <SelectItem value={NONE}>— Без клиента —</SelectItem>
                  {customers.map((c:any) => <SelectItem key={c.id} value={c.id}>{c.fullName} · {c.phone} · {c.tier} · {c.points||0} б.</SelectItem>)}
                </SelectContent>
              </Select>
              <div className="flex items-center gap-2">
                <Label className="text-sm">Скидка чека, %</Label>
                <Input type="number" className="w-20" value={discountPct} onChange={(e)=>setDiscountPct(Math.max(0, Number(e.target.value||0)))} />
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {cart.length === 0 ? (
              <div className="text-sm text-muted-foreground">Добавьте товары/услуги слева…</div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Позиция</TableHead>
                    <TableHead className="text-right">Кол-во</TableHead>
                    <TableHead className="text-right">Вес</TableHead>
                    <TableHead className="text-right">Цена</TableHead>
                    <TableHead className="text-right">Скидка%</TableHead>
                    <TableHead className="text-right">Итого</TableHead>
                    <TableHead></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {cart.map((it, idx) => (
                    <TableRow key={idx}>
                      <TableCell>{it.name}</TableCell>
                      <TableCell className="text-right">
                        {it.weightKg ? (
                          <Badge variant="outline">1</Badge>
                        ) : (
                          <div className="flex items-center justify-end gap-1">
                            <Button size="icon" variant="outline" onClick={()=>updateQty(idx, -1)}><Minus className="h-3 w-3"/></Button>
                            <div className="w-7 text-center">{it.qty}</div>
                            <Button size="icon" variant="outline" onClick={()=>updateQty(idx, 1)}><Plus className="h-3 w-3"/></Button>
                          </div>
                        )}
                      </TableCell>
                      <TableCell className="text-right">{it.weightKg ? kg(it.weightKg) : "—"}</TableCell>
                      <TableCell className="text-right">{currency(it.unitPrice)}</TableCell>
                      <TableCell className="text-right">
                        <Input type="number" className="w-20 ml-auto" value={it.discountPct} onChange={(e)=>applyItemDiscount(idx, Math.max(0, Number(e.target.value||0)))} />
                      </TableCell>
                      <TableCell className="text-right font-medium">{currency(it.total)}</TableCell>
                      <TableCell className="text-right"><Button size="icon" variant="ghost" onClick={()=>removeItem(idx)}><Trash2 className="h-4 w-4"/></Button></TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
          <CardFooter className="flex items-center justify-between">
            <div className="text-sm text-muted-foreground">Позиции: {cart.length}</div>
            <div className="text-right space-y-1">
              <div className="text-sm">Подытог: <span className="font-medium">{currency(totals.sub)}</span></div>
              <div className="text-sm">Скидка чека: −{currency(totals.disc)}</div>
              <div className="text-lg font-bold">Итого к оплате: {currency(totals.grand)}</div>
              <Dialog open={payOpen} onOpenChange={setPayOpen}>
                <DialogTrigger asChild>
                  <Button disabled={cart.length===0}>Оплатить</Button>
                </DialogTrigger>
                <PayDialog onCancel={()=>setPayOpen(false)} onConfirm={(p:any)=>{ setPayOpen(false); handlePaid(p); }} amount={totals.grand} customerId={customerId} customers={customers} setCustomers={setCustomers} settings={settings}/>
              </Dialog>
            </div>
          </CardFooter>
        </Card>
      </div>

      <div className="space-y-4">
        <Card>
          <CardHeader className="pb-1 flex flex-row items-center justify-between">
            <div className="flex items-center gap-2"><Scale className="h-5 w-5"/><CardTitle>Весы</CardTitle></div>
            <div className="flex items-center gap-2 text-sm"><Label>Симуляция</Label><Switch checked={connected} onCheckedChange={setConnected}/></div>
          </CardHeader>
          <CardContent className="space-y-2">
            <div className="text-4xl font-bold tabular-nums">{kg(liveWeight as any)}</div>
            <div className="text-xs text-muted-foreground">Округление: {settings.weight.rounding.toFixed(2)} кг · Протокол: {settings.weight.protocol}</div>
            <div className="text-sm">Нажмите на весовой товар слева, чтобы добавить с текущим весом.</div>
          </CardContent>
        </Card>

        <LastOrdersMini />
      </div>
    </div>
  );
}

function LastOrdersMini(){
  const [orders, setOrders] = useState<any[]>([]);
  useEffect(()=>{ setOrders(loadLS(LS.orders, [])); }, []);
  return (
    <Card>
      <CardHeader className="pb-2"><CardTitle className="text-base">Последние продажи</CardTitle></CardHeader>
      <CardContent>
        <div className="space-y-2 max-h-[220px] overflow-auto pr-2">
          {orders.slice(0,8).map((o:any) => (
            <div key={o.id} className="p-2 rounded-xl border flex items-center justify-between">
              <div>
                <div className="text-sm font-medium">{o.number}</div>
                <div className="text-xs text-muted-foreground">{new Date(o.paidAt).toLocaleString("ru-RU")}</div>
              </div>
              <div className="text-sm font-semibold">{currency(o.totals.grand)}</div>
            </div>
          ))}
          {orders.length===0 && <div className="text-sm text-muted-foreground">Пока нет.</div>}
        </div>
      </CardContent>
    </Card>
  );
}

function PayDialog({ amount, onCancel, onConfirm, customerId, customers, setCustomers, settings }:
 { amount:number, onCancel:()=>void, onConfirm:(p:any[])=>void, customerId:string|null, customers:any[], setCustomers:any, settings:any }){
  const [cash, setCash] = useState(0);
  const [card, setCard] = useState(amount);
  const [usePoints, setUsePoints] = useState(0);

  const customer = customers.find((c:any)=>c.id===customerId);
  const maxRedeemRub = customer ? Math.min((customer.points||0) * (settings.loyalty.redeemRate||1), amount) : 0;

  const due = Math.max(0, amount - (cash + card + usePoints));

  return (
    <DialogContent>
      <DialogHeader>
        <DialogTitle>Оплата</DialogTitle>
        <DialogDescription>Сумма к оплате: {currency(amount)}</DialogDescription>
      </DialogHeader>
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Wallet className="h-4 w-4"/><Label className="w-32">Наличные</Label>
          <Input type="number" value={cash} onChange={(e)=>setCash(Number(e.target.value||0))} />
        </div>
        <div className="flex items-center gap-2">
          <CreditCard className="h-4 w-4"/><Label className="w-32">Карта</Label>
          <Input type="number" value={card} onChange={(e)=>setCard(Number(e.target.value||0))} />
        </div>
        <div className="flex items-center gap-2">
          <Label className="w-32">Баллы (₽)</Label>
          <Input type="number" value={usePoints} onChange={(e)=>{
            const v = Math.max(0, Number(e.target.value||0));
            setUsePoints(Math.min(v, maxRedeemRub));
          }} />
          <div className="text-xs text-muted-foreground">Доступно: {currency(maxRedeemRub)}</div>
        </div>
        <div className={`text-sm ${due===0?"text-green-600":"text-amber-600"}`}>Остаток: {currency(due)}</div>
      </div>
      <DialogFooter>
        <Button variant="outline" onClick={onCancel}>Отмена</Button>
        <Button disabled={due!==0} onClick={()=>{
          if (customer && usePoints>0){
            const toBurnPts = Math.ceil(usePoints / (settings.loyalty.redeemRate||1));
            setCustomers((cs:any[]) => cs.map(c => c.id===customer.id ? { ...c, points: Math.max(0, (c.points||0) - toBurnPts) } : c));
          }
          onConfirm([
            cash>0 && { method: "CASH", amount: cash },
            card>0 && { method: "CARD", amount: card },
            usePoints>0 && { method: "LOYALTY", amount: usePoints },
          ].filter(Boolean));
        }}>Подтвердить</Button>
      </DialogFooter>
    </DialogContent>
  );
}

// ---------- Reservations ----------
function Reservations({ gazebos, customers, reservations, setReservations }:{
  gazebos:any[], customers:any[], reservations:any[], setReservations:any
}){
  const [date, setDate] = useState(todayISO());
  const [selGazebo, setSelGazebo] = useState<string>(gazebos[0]?.id ?? NONE);
  const hours = Array.from({length: 15}, (_,i)=> i+8); // 08..22

  const dayRes = useMemo(() => {
    if (selGazebo === NONE) return [];
    return reservations.filter(r => r.startAt.slice(0,10)===date && r.resourceId===selGazebo);
  }, [reservations, date, selGazebo]);

  function toggleSlot(hour:number){
    if (selGazebo === NONE) return;
    const startAt = new Date(`${date}T${String(hour).padStart(2,'0')}:00:00`).toISOString();
    const endAt = new Date(`${date}T${String(hour+1).padStart(2,'0')}:00:00`).toISOString();
    const existing = (dayRes as any[]).find(r => r.startAt===startAt);
    if (existing){
      setReservations(reservations.filter(r => r.id !== existing.id));
    } else {
      if (customers.length===0) return;
      const r = { id: `r_${Date.now()}_${hour}`, resourceId: selGazebo, customerId: customers[0].id, status: "HELD", startAt, endAt, prepayAmount: 0 };
      setReservations([r, ...reservations]);
    }
  }

  const isBooked = (hour:number) => (dayRes as any[]).some(r => r.startAt.slice(11,13) === String(hour).padStart(2,'0'));

  return (
    <div className="grid md:grid-cols-3 gap-4">
      <Card className="md:col-span-1">
        <CardHeader className="pb-2"><CardTitle>Параметры</CardTitle></CardHeader>
        <CardContent className="space-y-3">
          <div>
            <Label>Дата</Label>
            <Input type="date" value={date} onChange={(e)=>setDate(e.target.value)} />
          </div>
          <div>
            <Label>Беседка</Label>
            <Select value={selGazebo} onValueChange={setSelGazebo}>
              <SelectTrigger><SelectValue placeholder="Выберите беседку"/></SelectTrigger>
              <SelectContent>
                <SelectItem value={NONE}>— Выберите беседку —</SelectItem>
                {gazebos.map((g:any) => <SelectItem key={g.id} value={g.id}>{g.name} · {g.capacity} мест</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="text-sm text-muted-foreground">Клик по часу — забронировать/снять.</div>
        </CardContent>
      </Card>

      <Card className="md:col-span-2">
        <CardHeader className="pb-2"><CardTitle>Слоты на день</CardTitle></CardHeader>
        <CardContent>
          <div className="grid grid-cols-3 md:grid-cols-5 lg:grid-cols-6 gap-2">
            {hours.map(h => (
              <button key={h} onClick={()=>toggleSlot(h)} disabled={selGazebo===NONE} className={`rounded-2xl p-3 border text-left ${selGazebo===NONE?"opacity-50 cursor-not-allowed": isBooked(h)?"bg-green-50 border-green-300":"hover:shadow"}`}>
                <div className="text-sm font-medium">{String(h).padStart(2,'0')}:00 – {String(h+1).padStart(2,'0')}:00</div>
                <div className="text-xs text-muted-foreground">{selGazebo===NONE?"Выберите беседку": isBooked(h)?"Забронировано":"Свободно"}</div>
              </button>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

// ---------- CRM ----------
function CRM({ customers, setCustomers, orders }:{customers:any[], setCustomers:any, orders:any[]}){
  const [q, setQ] = useState("");
  const [fullName, setFullName] = useState("");
  const [phone, setPhone] = useState("");

  const filtered = useMemo(() => customers.filter(c => (c.fullName+" "+c.phone).toLowerCase().includes(q.toLowerCase())), [customers, q]);

  function addCustomer(){
    if (!fullName || !phone) return;
    const id = `c_${Date.now()}`;
    setCustomers([{ id, fullName, phone, tier: "Bronze", points: 0 }, ...customers]);
    setFullName(""); setPhone("");
  }

  const spentByCustomer = useMemo(() => {
    const m:any = {};
    orders.forEach(o => { if (!o.customerId) return; m[o.customerId] = (m[o.customerId]||0) + (o.totals?.grand||0); });
    return m;
  }, [orders]);

  return (
    <div className="grid md:grid-cols-3 gap-4">
      <Card>
        <CardHeader className="pb-2"><CardTitle>Добавить клиента</CardTitle></CardHeader>
        <CardContent className="space-y-2">
          <div>
            <Label>ФИО</Label>
            <Input value={fullName} onChange={(e)=>setFullName(e.target.value)} />
          </div>
          <div>
            <Label>Телефон</Label>
            <Input value={phone} onChange={(e)=>setPhone(e.target.value)} />
          </div>
          <Button onClick={addCustomer}>Сохранить</Button>
        </CardContent>
      </Card>

      <Card className="md:col-span-2">
        <CardHeader className="pb-2 flex items-center justify-between">
          <CardTitle>Клиенты</CardTitle>
          <Input placeholder="Поиск" value={q} onChange={(e)=>setQ(e.target.value)} className="w-64"/>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>ФИО</TableHead>
                <TableHead>Телефон</TableHead>
                <TableHead>Тир</TableHead>
                <TableHead className="text-right">Баллы</TableHead>
                <TableHead className="text-right">Потрачено</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filtered.map((c:any) => (
                <TableRow key={c.id}>
                  <TableCell>{c.fullName}</TableCell>
                  <TableCell>{c.phone}</TableCell>
                  <TableCell>{c.tier}</TableCell>
                  <TableCell className="text-right">{c.points||0}</TableCell>
                  <TableCell className="text-right">{currency((spentByCustomer as any)[c.id]||0)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}

// ---------- Reports ----------
function Reports({ orders, reservations, products }:{orders:any[], reservations:any[], products:any[]}) {
  const daily = useMemo(() => {
    const byDay:any = {};
    orders.forEach(o => {
      const d = o.paidAt?.slice(0,10) || o.createdAt.slice(0,10);
      byDay[d] = (byDay[d]||0) + (o.totals?.grand||0);
    });
    return Object.entries(byDay).sort((a:any,b:any)=>a[0].localeCompare(b[0])).map(([date, total]) => ({ date, total }));
  }, [orders]);

  const byProduct = useMemo(() => {
    const map:any = {};
    orders.forEach(o => o.items.forEach((it:any) => { map[it.name] = (map[it.name]||0) + (it.total||0); }));
    return Object.entries(map).sort((a:any,b:any)=>b[1]-a[1]).slice(0,6).map(([name, amount]) => ({ name, amount }));
  }, [orders]);

  const fishCatch = useMemo(() => {
    const map:any = {};
    orders.forEach(o => o.items.forEach((it:any) => {
      const p = products.find((x:any) => x.id===it.productId);
      if (p && p.isWeightable) { map[p.name] = (map[p.name]||0) + (it.weightKg||0); }
    }));
    return Object.entries(map).map(([name, kgv]:any) => ({ name, kg: Number(kgv.toFixed(2)) }));
  }, [orders, products]);

  const gazeboLoad = useMemo(() => {
    const byDate:any = {};
    reservations.forEach(r => { const d = r.startAt.slice(0,10); byDate[d] = (byDate[d]||0) + 1; });
    return Object.entries(byDate).map(([date, slots]:any) => ({ date, slots }));
  }, [reservations]);

  const totalRevenue = orders.reduce((s,o)=>s+(o.totals?.grand||0),0);
  const avgCheck = orders.length ? totalRevenue/orders.length : 0;

  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <Card>
        <CardHeader className="pb-2"><CardTitle>Динамика выручки (по дням)</CardTitle></CardHeader>
        <CardContent>
          <div className="h-[240px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={daily}>
                <XAxis dataKey="date"/><YAxis/><Tooltip/><Legend/>
                <Line type="monotone" dataKey="total" name="Выручка" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="pb-2"><CardTitle>Топ продаж (позиции)</CardTitle></CardHeader>
        <CardContent>
          <div className="h-[240px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={byProduct}>
                <XAxis dataKey="name" tick={{ fontSize: 12 }} interval={0} angle={-15} textAnchor="end" height={60}/>
                <YAxis/><Tooltip/><Legend/>
                <Bar dataKey="amount" name="Продажи (₽)" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      <Card className="lg:col-span-2">
        <CardHeader className="pb-2"><CardTitle>Итоги</CardTitle></CardHeader>
        <CardContent className="grid md:grid-cols-4 gap-3">
          <Stat title="Выручка" value={currency(totalRevenue)} />
          <Stat title="Средний чек" value={currency(avgCheck)} />
          <Stat title="Чеков" value={orders.length} />
          <Stat title="Бронирований" value={reservations.length} />
        </CardContent>
      </Card>
    </div>
  );
}

function Stat({ title, value }:{title:string, value:string|number}){
  return (
    <div className="rounded-2xl border p-4">
      <div className="text-sm text-muted-foreground">{title}</div>
      <div className="text-xl font-semibold mt-1">{value}</div>
    </div>
  );
}

// ---------- Admin ----------
function Admin({ products, setProducts, settings, setSettings }:{
  products:any[], setProducts:any, settings:any, setSettings:any
}){
  const [name, setName] = useState("");
  const [group, setGroup] = useState("Рыба");
  const [type, setType] = useState("GOOD");
  const [unit, setUnit] = useState("KG");
  const [isWeightable, setIsWeightable] = useState(true);
  const [price, setPrice] = useState<any>(0);

  function addProduct(){
    if (!name) return;
    const id = `p_${Date.now()}`;
    setProducts([{ id, name, type, unit, isWeightable, price: Number(price||0), group, isActive: true }, ...products]);
    setName(""); setPrice(0); setIsWeightable(unit==="KG"); setType("GOOD"); setGroup("Рыба");
  }

  function toggleActive(id:string){ setProducts(products.map((p:any) => p.id===id ? { ...p, isActive: !p.isActive } : p)); }

  return (
    <div className="grid md:grid-cols-3 gap-4">
      <Card>
        <CardHeader className="pb-2"><CardTitle>Новый товар/услуга</CardTitle></CardHeader>
        <CardContent className="space-y-2">
          <div>
            <Label>Название</Label>
            <Input value={name} onChange={(e)=>setName(e.target.value)} />
          </div>
          <div className="grid grid-cols-2 gap-2">
            <div>
              <Label>Группа</Label>
              <Select value={group} onValueChange={setGroup}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  {['Рыба','Вход','Беседки','Допы'].map(g => <SelectItem key={g} value={g}>{g}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label>Тип</Label>
              <Select value={type} onValueChange={(v)=>{ setType(v); if (v==="SERVICE" && unit==="KG") setUnit("HOUR"); }}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="GOOD">GOOD</SelectItem>
                  <SelectItem value="SERVICE">SERVICE</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-2">
            <div>
              <Label>Ед.</Label>
              <Select value={unit} onValueChange={(v)=>{ setUnit(v); setIsWeightable(v==="KG"); }}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="KG">KG</SelectItem>
                  <SelectItem value="HOUR">HOUR</SelectItem>
                  <SelectItem value="PIECE">PIECE</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label>Цена</Label>
              <Input type="number" value={price} onChange={(e)=>setPrice(e.target.value)} />
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Switch checked={isWeightable} onCheckedChange={setIsWeightable} disabled={unit!=="KG"} />
            <Label>Весовой товар</Label>
          </div>
          <Button onClick={addProduct}>Сохранить</Button>
        </CardContent>
      </Card>

      <Card className="md:col-span-2">
        <CardHeader className="pb-2"><CardTitle>Номенклатура</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Название</TableHead>
                <TableHead>Группа</TableHead>
                <TableHead>Тип</TableHead>
                <TableHead>Ед.</TableHead>
                <TableHead className="text-right">Цена</TableHead>
                <TableHead className="text-right">Статус</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {products.map((p:any) => (
                <TableRow key={p.id}>
                  <TableCell>{p.name}</TableCell>
                  <TableCell>{p.group||""}</TableCell>
                  <TableCell>{p.type}</TableCell>
                  <TableCell>{p.unit}</TableCell>
                  <TableCell className="text-right">{currency(p.price)}</TableCell>
                  <TableCell className="text-right">
                    <Button size="sm" variant={p.isActive?"secondary":"outline"} onClick={()=>toggleActive(p.id)}>
                      {p.isActive?"Активен":"Откл."}
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card className="md:col-span-3">
        <CardHeader className="pb-2"><CardTitle>Настройки</CardTitle></CardHeader>
        <CardContent className="grid md:grid-cols-3 gap-4">
          <div className="rounded-2xl border p-3 space-y-2">
            <div className="font-medium">Весы</div>
            <div className="grid grid-cols-2 gap-2 items-center">
              <Label>Округление (кг)</Label>
              <Input type="number" step="0.01" value={settings.weight.rounding} onChange={(e)=>setSettings({...settings, weight: { ...settings.weight, rounding: Number(e.target.value||0.01) }})}/>
              <Label>Протокол</Label>
              <Select value={settings.weight.protocol} onValueChange={(v)=>setSettings({...settings, weight:{...settings.weight, protocol:v}})}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  {['AUTODETECT','RS232','TCPIP'].map(p => <SelectItem key={p} value={p}>{p}</SelectItem>)}
                </SelectContent>
              </Select>
              <Label>Симуляция</Label>
              <Switch checked={settings.weight.simulateScale} onCheckedChange={(v)=>setSettings({...settings, weight:{...settings.weight, simulateScale:v}})} />
            </div>
          </div>
          <div className="rounded-2xl border p-3 space-y-2">
            <div className="font-medium">Лояльность</div>
            <div className="grid grid-cols-2 gap-2 items-center">
              <Label>Earn rate</Label>
              <Input type="number" step="0.01" value={settings.loyalty.earnRate} onChange={(e)=>setSettings({...settings, loyalty:{...settings.loyalty, earnRate:Number(e.target.value||0)}})} />
              <Label>Redeem ₽/балл</Label>
              <Input type="number" value={settings.loyalty.redeemRate} onChange={(e)=>setSettings({...settings, loyalty:{...settings.loyalty, redeemRate:Number(e.target.value||1)}})} />
              <Label>Мин. чек для earn</Label>
              <Input type="number" value={settings.loyalty.minOrderForEarn} onChange={(e)=>setSettings({...settings, loyalty:{...settings.loyalty, minOrderForEarn:Number(e.target.value||0)}})} />
            </div>
          </div>
          <div className="rounded-2xl border p-3 space-y-2">
            <div className="font-medium">Прочее</div>
            <div className="text-sm text-muted-foreground">Версия демо-интерфейса без сервера. Все данные в браузере.</div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
TSX

# ----------------------------
# Установка зависимостей
# ----------------------------
echo "==> Installing dependencies (requires Node.js 18+ and internet)"
( cd "$APP_DIR" && npm i )

# ----------------------------
# Установка shadcn/ui
# ----------------------------
echo "==> Installing shadcn/ui components"
( cd "$APP_DIR" && npx --yes shadcn@latest init -y >/dev/null 2>&1 || true )
( cd "$APP_DIR" && npx --yes shadcn@latest add button card tabs input label badge table dialog select switch scroll-area )

# ----------------------------
# Сборка (Next 14: output:'export' => out/ создаётся на build)
# ----------------------------
echo "==> Building (static export via next build)"
( cd "$APP_DIR" && npm run build )

# ----------------------------
# Инсталлятор для шаред-хостинга (PHP)
# ----------------------------
cat > "$APP_DIR/installer.php" <<'PHP'
<?php
@ini_set('max_execution_time', 0);
header('Content-Type: text/plain; charset=utf-8');
$zipFile = __DIR__ . '/site.zip';
if (!file_exists($zipFile)) { http_response_code(400); echo "site.zip not found\n"; exit; }
$zip = new ZipArchive();
if ($zip->open($zipFile) === TRUE) {
  $zip->extractTo(__DIR__);
  $zip->close();
  echo "Unpacked site.zip\n";
  $ht = __DIR__.'/.htaccess';
  if (!file_exists($ht)) {
    file_put_contents($ht, "AddType application/javascript .js\nAddType text/css .css\nAddType text/html .html\nAddDefaultCharset utf-8\n");
  }
  echo "Done.\n";
} else {
  http_response_code(500);
  echo "Failed to open site.zip\n";
}
PHP

# ----------------------------
# Упаковка out/ в site.zip
# ----------------------------
echo "==> Zipping out/ into site.zip for shared hosting"
if ! command -v zip >/dev/null 2>&1; then
  echo "!! 'zip' не найден. Установите zip (macOS: 'brew install zip'), либо загрузите папку out/ напрямую на хостинг."
else
  ( cd "$APP_DIR/out" && zip -qr ../site.zip . )
fi

cat <<'TXT'

Build finished ✅

Готово к деплою:
  • Готовая статика: ./'"$APP_DIR"'/out
  • Архив для шаред-хостинга: ./'"$APP_DIR"'/site.zip
  • Веб-инсталлятор: ./'"$APP_DIR"'/installer.php

Деплой:
  1) SFTP/SSH (рекомендовано):
     scp -r '"$APP_DIR"'/out/* user@host:/path/to/public_html/

  2) Шаред-хостинг (без SSH):
     загрузите файлы '"$APP_DIR"'/site.zip и '"$APP_DIR"'/installer.php в корень сайта,
     затем откройте https://ВАШ_ДОМЕН/installer.php — он распакует архив и добавит .htaccess

  3) VPS как Node-приложение:
     Если нужно SSR/динамика — в next.config.js замените на { output: 'standalone' },
     затем: npm run build && node .next/standalone/server.js за Nginx-прокси.

TXT
