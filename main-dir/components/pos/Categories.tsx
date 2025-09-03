'use client';

import { Button } from "@/components/ui/button";

export default function Categories({ categories, current, onSelect }: { categories: string[]; current: string|null; onSelect: (c:string|null)=>void }) {
  return (
    <div className="flex flex-wrap gap-2">
      <Button
        variant={current == null ? "default" : "secondary"}
        onClick={() => onSelect(null)}
      >
        Все
      </Button>
      {categories.map(c => (
        <Button
          key={c}
          variant={current === c ? "default" : "secondary"}
          onClick={() => onSelect(c)}
        >
          {c}
        </Button>
      ))}
    </div>
  );
}
