"use client";

import { useState, FormEvent } from "react";
import InputMask from "react-input-mask";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";

export interface CustomerFormProps {
  initial?: { fullName?: string; phones?: string[] };
  onSubmit: (payload: { fullName: string; phones: string[] }) => void;
}

export function CustomerForm({ initial, onSubmit }: CustomerFormProps) {
  const [fullName, setFullName] = useState(initial?.fullName ?? "");
  const [phones, setPhones] = useState<string[]>(initial?.phones ?? [""]);

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    onSubmit({ fullName, phones: phones.filter((p) => p.trim() !== "") });
  }

  function updatePhone(i: number, value: string) {
    setPhones((prev) => prev.map((p, idx) => (idx === i ? value : p)));
  }

  function addPhone() {
    setPhones([...phones, ""]);
  }

  function removePhone(i: number) {
    setPhones((prev) => prev.filter((_, idx) => idx !== i));
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
        <Label htmlFor="phone0">Телефоны</Label>
        {phones.map((p, i) => (
          <div key={i} className="flex items-center space-x-2 mt-1">
            <InputMask
              mask="+7 (999) 999-99-99"
              value={p}
              onChange={(e) => updatePhone(i, e.target.value)}
            >
              {(inputProps: any) => <Input id={`phone${i}`} {...inputProps} />}
            </InputMask>
            {phones.length > 1 && (
              <Button
                type="button"
                variant="ghost"
                onClick={() => removePhone(i)}
              >
                Удалить
              </Button>
            )}
          </div>
        ))}
        <Button
          type="button"
          variant="secondary"
          className="mt-1"
          onClick={addPhone}
        >
          Добавить телефон
        </Button>
      </div>
      <Button type="submit">Сохранить</Button>
    </form>
  );
}

export default CustomerForm;

