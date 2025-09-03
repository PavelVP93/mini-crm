import type { Role } from "../roles/types";

export interface User {
  id: string;
  fullName: string;
  email: string;
  roles: string[]; // role ids
}

export type { Role };

