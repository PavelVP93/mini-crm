"use client";

import { useState, FormEvent, ChangeEvent } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Tooltip } from "@/components/ui/tooltip";
import { Info } from "lucide-react";

export interface WeightProductProps {
  onSubmit: (payload: { weightKg: number }) => void;
}

export default function WeightProduct({ onSubmit }: WeightProductProps) {
  const [weight, setWeight] = useState("");

  function handleWeightChange(e: ChangeEvent<HTMLInputElement>) {
    const value = e.target.value;
    if (value === "" || /^\d+(\.\d{0,2})?$/.test(value)) {
      setWeight(value);
    }
  }

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const w = parseFloat(weight);
    if (!isNaN(w)) {
      onSubmit({ weightKg: w });
      setWeight("");
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-2">
      <div className="flex justify-end">
        <Tooltip content="Введите вес товара и нажмите «Добавить»">
          <Info className="h-4 w-4 text-muted-foreground cursor-pointer" />
        </Tooltip>
      </div>
      <div>
        <Label htmlFor="weight">Вес (кг)</Label>
        <Input
          id="weight"
          type="number"
          min="0"
          step={0.01}
          value={weight}
          onChange={handleWeightChange}
        />
      </div>
      <Button type="submit">Добавить</Button>
    </form>
  );
}
