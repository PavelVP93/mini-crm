"use client";

import { FormEvent, useEffect, useState } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import type { Role } from "./types";

export interface RoleFormProps {
  initial?: Role | null;
  onSaved: () => void;
}

export default function RoleForm({ initial, onSaved }: RoleFormProps) {
  const [name, setName] = useState(initial?.name ?? "");

  useEffect(() => {
    setName(initial?.name ?? "");
  }, [initial]);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const url = initial?.id ? `/api/roles/${initial.id}` : "/api/roles";
    await fetch(url, {
      method: initial?.id ? "PUT" : "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name }),
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
      <Button type="submit">Сохранить</Button>
    </form>
  );
}

