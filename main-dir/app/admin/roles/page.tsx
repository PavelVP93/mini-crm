"use client";

import { useEffect, useState } from "react";
import RoleForm from "./RoleForm";
import RoleList from "./RoleList";
import type { Role } from "./types";

export default function RolesPage() {
  const [roles, setRoles] = useState<Role[]>([]);
  const [editing, setEditing] = useState<Role | null>(null);

  async function load() {
    const res = await fetch("/api/roles");
    setRoles(await res.json());
  }

  useEffect(() => {
    load();
  }, []);

  async function handleDelete(id: string) {
    await fetch(`/api/roles/${id}`, { method: "DELETE" });
    load();
  }

  function handleSaved() {
    setEditing(null);
    load();
  }

  return (
    <div className="p-4 space-y-4">
      <h1 className="text-xl font-bold">Roles</h1>
      <RoleForm initial={editing} onSaved={handleSaved} />
      <RoleList roles={roles} onEdit={(r) => setEditing(r)} onDelete={handleDelete} />
    </div>
  );
}

