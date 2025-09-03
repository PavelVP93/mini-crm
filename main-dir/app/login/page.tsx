'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export default function LoginPage() {
  const router = useRouter();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    const res = await fetch('/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password })
    });
    if (res.ok) {
      router.push('/');
    } else {
      setError('Неверный логин или пароль');
    }
  };

  return (
    <div className="h-screen flex items-center justify-center">
      <form onSubmit={onSubmit} className="space-y-4 p-6 border rounded-lg w-full max-w-sm">
        <div className="text-xl font-bold">Вход</div>
        <div className="space-y-2">
          <Label htmlFor="username">Логин</Label>
          <Input id="username" value={username} onChange={(e) => setUsername(e.target.value)} />
        </div>
        <div className="space-y-2">
          <Label htmlFor="password">Пароль</Label>
          <Input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </div>
        {error && <div className="text-sm text-red-500">{error}</div>}
        <Button type="submit" className="w-full">Войти</Button>
      </form>
    </div>
  );
}
