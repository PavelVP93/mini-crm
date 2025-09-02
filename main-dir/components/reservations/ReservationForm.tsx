"use client";

import { useState, FormEvent } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
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
}

export interface ReservationFormProps {
  customers: CustomerOption[];
  onSubmit: (payload: Record<string, unknown>) => void;
}

export function ReservationForm({ customers, onSubmit }: ReservationFormProps) {
  const [customerId, setCustomerId] = useState("");
  const [newCustomerName, setNewCustomerName] = useState("");
  const [newCustomerPhone, setNewCustomerPhone] = useState("");

  async function createCustomer() {
    const res = await fetch("/api/customers", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ fullName: newCustomerName, phone: newCustomerPhone }),
    });
    const data = await res.json();
    setCustomerId(data.id);
    return data.id as string;
  }

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!customerId) {
      alert("Customer is required");
      return;
    }
    let id = customerId;
    if (id === "new") {
      id = await createCustomer();
    }
    const form = new FormData(e.currentTarget);
    onSubmit({
      customer_id: id,
      startAt: form.get("startAt"),
      endAt: form.get("endAt"),
      notes: form.get("notes"),
    });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="customer">Customer</Label>
        <Select value={customerId} onValueChange={setCustomerId} aria-required="true">
          <SelectTrigger id="customer">
            <SelectValue placeholder="Select customer" />
          </SelectTrigger>
          <SelectContent>
            {customers.map((c) => (
              <SelectItem key={c.id} value={c.id}>
                {c.fullName}
              </SelectItem>
            ))}
            <SelectItem value="new">+ Create new</SelectItem>
          </SelectContent>
        </Select>
      </div>
      {customerId === "new" && (
        <div className="space-y-2">
          <Label htmlFor="newName">Name</Label>
          <Input
            id="newName"
            value={newCustomerName}
            onChange={(e) => setNewCustomerName(e.target.value)}
          />
          <Label htmlFor="newPhone">Phone</Label>
          <Input
            id="newPhone"
            value={newCustomerPhone}
            onChange={(e) => setNewCustomerPhone(e.target.value)}
          />
        </div>
      )}
      <div className="space-y-2">
        <Label htmlFor="startAt">Start</Label>
        <Input id="startAt" name="startAt" type="datetime-local" />
      </div>
      <div className="space-y-2">
        <Label htmlFor="endAt">End</Label>
        <Input id="endAt" name="endAt" type="datetime-local" />
      </div>
      <div className="space-y-2">
        <Label htmlFor="notes">Notes</Label>
        <Input id="notes" name="notes" />
      </div>
      <Button type="submit" disabled={!customerId}>Save</Button>
    </form>
  );
}

export default ReservationForm;
