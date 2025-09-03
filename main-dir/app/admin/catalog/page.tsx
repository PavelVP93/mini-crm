"use client";

import { useEffect, useState } from "react";
import CatalogForm from "./CatalogForm";
import CatalogList from "./CatalogList";
import type { CatalogItem } from "./types";

export default function CatalogPage() {
  const [items, setItems] = useState<CatalogItem[]>([]);
  const [editing, setEditing] = useState<CatalogItem | null>(null);

  async function load() {
    const res = await fetch("/api/catalog");
    const data = await res.json();
    setItems(data);
  }

  useEffect(() => {
    load();
  }, []);

  async function handleDelete(id: string) {
    await fetch(`/api/catalog/${id}`, { method: "DELETE" });
    load();
  }

  function handleSaved() {
    setEditing(null);
    load();
  }

  return (
    <div className="p-4 space-y-4">
      <h1 className="text-xl font-bold">Catalog</h1>
      <CatalogForm initial={editing} onSaved={handleSaved} />
      <CatalogList items={items} onEdit={setEditing} onDelete={handleDelete} />
    </div>
  );
}
