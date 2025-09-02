"use client";

import { Button } from "@/components/ui/button";

export interface Product {
  id: string;
  name: string;
  currentPrice?: number;
}

export interface ProductListProps {
  products: Product[];
  onEdit: (p: Product) => void;
  onDelete: (id: string) => void;
}

export default function ProductList({ products, onEdit, onDelete }: ProductListProps) {
  if (products.length === 0) {
    return <p>Нет товаров</p>;
  }
  return (
    <div className="space-y-2">
      {products.map((p) => (
        <div
          key={p.id}
          className="flex items-center justify-between border rounded p-2"
        >
          <div>
            <div className="font-medium">{p.name}</div>
            {p.currentPrice !== undefined && (
              <div className="text-sm text-muted-foreground">
                {p.currentPrice}
              </div>
            )}
          </div>
          <div className="space-x-2">
            <Button size="sm" onClick={() => onEdit(p)}>
              Редактировать
            </Button>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => onDelete(p.id)}
            >
              Удалить
            </Button>
          </div>
        </div>
      ))}
    </div>
  );
}

