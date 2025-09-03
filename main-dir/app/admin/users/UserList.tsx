"use client";

import { Button } from "@/components/ui/button";
import type { User, Role } from "./types";

export interface UserListProps {
  users: User[];
  roles: Role[];
  onEdit: (u: User) => void;
  onDelete: (id: string) => void;
}

export default function UserList({ users, roles, onEdit, onDelete }: UserListProps) {
  if (users.length === 0) return <p>Нет пользователей</p>;
  const roleMap = Object.fromEntries(roles.map((r) => [r.id, r.name]));
  return (
    <div className="space-y-2">
      {users.map((u) => (
        <div
          key={u.id}
          className="flex items-center justify-between border rounded p-2"
        >
          <div>
            <div className="font-medium">{u.fullName}</div>
            <div className="text-sm text-muted-foreground">{u.email}</div>
            {u.roles.length > 0 && (
              <div className="text-sm">
                {u.roles.map((id) => roleMap[id] ?? id).join(", ")}
              </div>
            )}
          </div>
          <div className="space-x-2">
            <Button size="sm" onClick={() => onEdit(u)}>
              Редактировать
            </Button>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => onDelete(u.id)}
            >
              Удалить
            </Button>
          </div>
        </div>
      ))}
    </div>
  );
}

