"use client";

import { useEffect, useState } from "react";
import LoyaltyForm from "./LoyaltyForm";
import LoyaltyList from "./LoyaltyList";
import type { LoyaltyProgram } from "./types";

export default function LoyaltyPage() {
  const [programs, setPrograms] = useState<LoyaltyProgram[]>([]);
  const [editing, setEditing] = useState<LoyaltyProgram | null>(null);

  async function load() {
    const res = await fetch("/api/loyalty");
    const data = await res.json();
    setPrograms(data);
  }

  useEffect(() => {
    load();
  }, []);

  async function handleDelete(id: string) {
    await fetch(`/api/loyalty/${id}`, { method: "DELETE" });
    load();
  }

  function handleSaved() {
    setEditing(null);
    load();
  }

  return (
    <div className="p-4 space-y-4">
      <h1 className="text-xl font-bold">Loyalty Programs</h1>
      <LoyaltyForm initial={editing} onSaved={handleSaved} />
      <LoyaltyList programs={programs} onEdit={setEditing} onDelete={handleDelete} />
    </div>
  );
}
