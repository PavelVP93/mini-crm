"use client";

import { useState, useEffect } from "react";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";

export interface CustomerOption {
  id: string;
  fullName: string;
  phones?: string[];
}

export interface CustomerSelectProps {
  value: string;
  onChange: (id: string) => void;
}

export function CustomerSelect({ value, onChange }: CustomerSelectProps) {
  const [query, setQuery] = useState("");
  const [customers, setCustomers] = useState<CustomerOption[]>([]);

  useEffect(() => {
    async function fetchCustomers() {
      const res = await fetch(
        `/api/customers/search?q=${encodeURIComponent(query)}`
      );
      const data = await res.json();
      setCustomers(data);
    }
    fetchCustomers();
  }, [query]);

  return (
    <div className="space-y-2">
      <Input
        placeholder="Поиск по имени или телефону"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      <Select value={value} onValueChange={onChange} aria-required="true">
        <SelectTrigger>
          <SelectValue placeholder="Выберите клиента" />
        </SelectTrigger>
        <SelectContent>
          {customers.map((c) => (
            <SelectItem key={c.id} value={c.id}>
              {c.fullName}
              {c.phones && c.phones[0] ? ` (${c.phones[0]})` : ""}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
}

export default CustomerSelect;

