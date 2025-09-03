export interface Product {
  id: string;
  name: string;
  sku?: string;
  type: "GOOD" | "SERVICE";
  unit: "KG" | "HOUR" | "PIECE";
  price?: number;
  currentPrice?: number;
}

