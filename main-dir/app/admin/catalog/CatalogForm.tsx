"use client";

import { FormEvent, useEffect, useState } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import type { CatalogItem } from "./types";

export interface CatalogFormProps {
  initial?: CatalogItem | null;
  onSaved: () => void;
}

export default function CatalogForm({ initial, onSaved }: CatalogFormProps) {
  const [name, setName] = useState(initial?.name ?? "");
  const [code, setCode] = useState(initial?.code ?? "");

  useEffect(() => {
    setName(initial?.name ?? "");
    setCode(initial?.code ?? "");
  }, [initial]);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const payload: any = { name };
    if (code !== "") payload.code = code;
    const url = initial?.id ? `/api/catalog/${initial.id}` : "/api/catalog";
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
        <Label htmlFor="code">Код</Label>
        <Input
          id="code"
          value={code}
          onChange={(e) => setCode(e.target.value)}
        />
      </div>
      <Button type="submit">Сохранить</Button>
    </form>
  );
}
