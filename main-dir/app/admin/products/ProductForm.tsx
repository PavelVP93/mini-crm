"use client";

import { FormEvent, useEffect, useState } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import type { Product } from "./types";

export interface ProductFormProps {
  initial?: Product | null;
  onSaved: () => void;
}

export default function ProductForm({ initial, onSaved }: ProductFormProps) {
  const [name, setName] = useState(initial?.name ?? "");
  const [sku, setSku] = useState(initial?.sku ?? "");
  const [type, setType] = useState<Product["type"]>(initial?.type ?? "GOOD");
  const [unit, setUnit] = useState<Product["unit"]>(initial?.unit ?? "PIECE");
  const [price, setPrice] = useState<string>(
    initial?.currentPrice?.toString() ?? initial?.price?.toString() ?? ""
  );

  useEffect(() => {
    setName(initial?.name ?? "");
    setSku(initial?.sku ?? "");
    setType(initial?.type ?? "GOOD");
    setUnit(initial?.unit ?? "PIECE");
    setPrice(initial?.currentPrice?.toString() ?? initial?.price?.toString() ?? "");
  }, [initial]);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const payload: any = { name, sku, type, unit };
    if (price !== "") payload.price = Number(price);
    const url = initial?.id ? `/api/products/${initial.id}` : "/api/products";
    await fetch(url, {
      method: initial?.id ? "PUT" : "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    onSaved();
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-2">
      <div>
        <Label htmlFor="name">Название</Label>
        <Input
          id="name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
        />
      </div>
      <div>
        <Label htmlFor="sku">SKU</Label>
        <Input id="sku" value={sku} onChange={(e) => setSku(e.target.value)} />
      </div>
      <div className="grid grid-cols-2 gap-2">
        <div>
          <Label>Тип</Label>
          <Select value={type} onValueChange={(v) => setType(v as any)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="GOOD">GOOD</SelectItem>
              <SelectItem value="SERVICE">SERVICE</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div>
          <Label>Ед.</Label>
          <Select value={unit} onValueChange={(v) => setUnit(v as any)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="KG">KG</SelectItem>
              <SelectItem value="HOUR">HOUR</SelectItem>
              <SelectItem value="PIECE">PIECE</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>
      <div>
        <Label htmlFor="price">Цена</Label>
        <Input
          id="price"
          type="number"
          value={price}
          onChange={(e) => setPrice(e.target.value)}
        />
      </div>
      <Button type="submit">Сохранить</Button>
    </form>
  );
}

