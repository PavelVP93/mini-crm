"use client";

import { Button } from "@/components/ui/button";
import type { LoyaltyProgram } from "./types";

export interface LoyaltyListProps {
  programs: LoyaltyProgram[];
  onEdit: (p: LoyaltyProgram) => void;
  onDelete: (id: string) => void;
}

export default function LoyaltyList({ programs, onEdit, onDelete }: LoyaltyListProps) {
  if (programs.length === 0) {
    return <p>Нет программ</p>;
  }
  return (
    <div className="space-y-2">
      {programs.map((p) => (
        <div
          key={p.id}
          className="flex items-center justify-between border rounded p-2"
        >
          <div>
            <div className="font-medium">{p.name}</div>
            {p.discount !== undefined && (
              <div className="text-sm text-muted-foreground">{p.discount}%</div>
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
