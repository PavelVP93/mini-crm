"use client";

import { Button } from "@/components/ui/button";
import type { CatalogItem } from "./types";

export interface CatalogListProps {
  items: CatalogItem[];
  onEdit: (p: CatalogItem) => void;
  onDelete: (id: string) => void;
}

export default function CatalogList({ items, onEdit, onDelete }: CatalogListProps) {
  if (items.length === 0) {
    return <p>Нет записей</p>;
  }
  return (
    <div className="space-y-2">
      {items.map((p) => (
        <div
          key={p.id}
          className="flex items-center justify-between border rounded p-2"
        >
          <div>
            <div className="font-medium">{p.name}</div>
            {p.code && (
              <div className="text-sm text-muted-foreground">{p.code}</div>
            )}
          </div>
          <div className="space-x-2">
            <Button size="sm" onClick={() => onEdit(p)}>
              Редактировать
            </Button>
            <Button size="sm" variant="destructive" onClick={() => onDelete(p.id)}>
              Удалить
            </Button>
          </div>
        </div>
      ))}
    </div>
  );
}
