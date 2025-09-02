"use client";

import { useEffect, useState } from "react";
import ProductForm from "./ProductForm";
import ProductList from "./ProductList";
import type { Product } from "./ProductForm";

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [editing, setEditing] = useState<Product | null>(null);

  async function load() {
    const res = await fetch("/api/products");
    const data = await res.json();
    setProducts(data);
  }

  useEffect(() => {
    load();
  }, []);

  async function handleDelete(id: string) {
    await fetch(`/api/products/${id}`, { method: "DELETE" });
    load();
  }

  function handleSaved() {
    setEditing(null);
    load();
  }

  return (
    <div className="p-4 space-y-4">
      <h1 className="text-xl font-bold">Products</h1>
      <ProductForm initial={editing} onSaved={handleSaved} />
      <ProductList
        products={products}
        onEdit={(p) => setEditing(p)}
        onDelete={handleDelete}
      />
    </div>
  );
}

