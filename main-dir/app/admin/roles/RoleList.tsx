"use client";

import { Button } from "@/components/ui/button";
import type { Role } from "./types";

export interface RoleListProps {
  roles: Role[];
  onEdit: (r: Role) => void;
  onDelete: (id: string) => void;
}

export default function RoleList({ roles, onEdit, onDelete }: RoleListProps) {
  if (roles.length === 0) return <p>Нет ролей</p>;
  return (
    <div className="space-y-2">
      {roles.map((r) => (
        <div
          key={r.id}
          className="flex items-center justify-between border rounded p-2"
        >
          <div className="font-medium">{r.name}</div>
          <div className="space-x-2">
            <Button size="sm" onClick={() => onEdit(r)}>
              Редактировать
            </Button>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => onDelete(r.id)}
            >
              Удалить
            </Button>
          </div>
        </div>
      ))}
    </div>
  );
}

