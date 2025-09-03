"use client";

import { FormEvent, useEffect, useState } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import type { User, Role } from "./types";

export interface UserFormProps {
  roles: Role[];
  initial?: User | null;
  onSaved: () => void;
}

export default function UserForm({ roles, initial, onSaved }: UserFormProps) {
  const [fullName, setFullName] = useState(initial?.fullName ?? "");
  const [email, setEmail] = useState(initial?.email ?? "");
  const [selected, setSelected] = useState<string[]>(initial?.roles ?? []);

  useEffect(() => {
    setFullName(initial?.fullName ?? "");
    setEmail(initial?.email ?? "");
    setSelected(initial?.roles ?? []);
  }, [initial]);

  function toggleRole(id: string) {
    setSelected((prev) =>
      prev.includes(id) ? prev.filter((r) => r !== id) : [...prev, id]
    );
  }

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const payload = { fullName, email, roles: selected };
    const url = initial?.id ? `/api/users/${initial.id}` : "/api/users";
    await fetch(url, {
      method: initial?.id ? "PATCH" : "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    onSaved();
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-2">
      <div>
        <Label htmlFor="fullName">Имя</Label>
        <Input
          id="fullName"
          value={fullName}
          onChange={(e) => setFullName(e.target.value)}
          required
        />
      </div>
      <div>
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />
      </div>
      <div className="space-y-1">
        <Label>Роли</Label>
        {roles.map((r) => (
          <label key={r.id} className="flex items-center space-x-2">
            <input
              type="checkbox"
              checked={selected.includes(r.id)}
              onChange={() => toggleRole(r.id)}
            />
            <span>{r.name}</span>
          </label>
        ))}
      </div>
      <Button type="submit">Сохранить</Button>
    </form>
  );
}

