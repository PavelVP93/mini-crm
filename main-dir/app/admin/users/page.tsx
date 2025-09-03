"use client";

import { useEffect, useState } from "react";
import UserForm from "./UserForm";
import UserList from "./UserList";
import type { User, Role } from "./types";

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [roles, setRoles] = useState<Role[]>([]);
  const [editing, setEditing] = useState<User | null>(null);

  async function load() {
    const [uRes, rRes] = await Promise.all([
      fetch("/api/users"),
      fetch("/api/roles"),
    ]);
    setUsers(await uRes.json());
    setRoles(await rRes.json());
  }

  useEffect(() => {
    load();
  }, []);

  async function handleDelete(id: string) {
    await fetch(`/api/users/${id}`, { method: "DELETE" });
    load();
  }

  function handleSaved() {
    setEditing(null);
    load();
  }

  return (
    <div className="p-4 space-y-4">
      <h1 className="text-xl font-bold">Users</h1>
      <UserForm roles={roles} initial={editing} onSaved={handleSaved} />
      <UserList
        users={users}
        roles={roles}
        onEdit={(u) => setEditing(u)}
        onDelete={handleDelete}
      />
    </div>
  );
}

