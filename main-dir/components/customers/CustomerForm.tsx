"use client";

import { useState, FormEvent } from "react";
import InputMask from "react-input-mask";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";

export interface CustomerFormProps {
  initial?: { fullName?: string; phone?: string };
  onSubmit: (payload: { fullName: string; phone: string }) => void;
}

export function CustomerForm({ initial, onSubmit }: CustomerFormProps) {
  const [fullName, setFullName] = useState(initial?.fullName ?? "");
  const [phone, setPhone] = useState(initial?.phone ?? "");

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    onSubmit({ fullName, phone });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-2">
      <div>
        <Label htmlFor="fullName">ФИО</Label>
        <Input
          id="fullName"
          value={fullName}
          onChange={(e) => setFullName(e.target.value)}
        />
      </div>
      <div>
        <Label htmlFor="phone">Телефон</Label>
        <InputMask
          mask="+7 (999) 999-99-99"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
        >
          {(inputProps: any) => <Input id="phone" {...inputProps} />}
        </InputMask>
      </div>
      <Button type="submit">Сохранить</Button>
    </form>
  );
}

export default CustomerForm;

