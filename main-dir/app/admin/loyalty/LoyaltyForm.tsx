"use client";

import { FormEvent, useEffect, useState } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import type { LoyaltyProgram } from "./types";

export interface LoyaltyFormProps {
  initial?: LoyaltyProgram | null;
  onSaved: () => void;
}

export default function LoyaltyForm({ initial, onSaved }: LoyaltyFormProps) {
  const [name, setName] = useState(initial?.name ?? "");
  const [discount, setDiscount] = useState(
    initial?.discount?.toString() ?? ""
  );

  useEffect(() => {
    setName(initial?.name ?? "");
    setDiscount(initial?.discount?.toString() ?? "");
  }, [initial]);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const payload: any = { name };
    if (discount !== "") payload.discount = Number(discount);
    const url = initial?.id ? `/api/loyalty/${initial.id}` : "/api/loyalty";
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
        <Label htmlFor="discount">Скидка %</Label>
        <Input
          id="discount"
          type="number"
          value={discount}
          onChange={(e) => setDiscount(e.target.value)}
        />
      </div>
      <Button type="submit">Сохранить</Button>
    </form>
  );
}
