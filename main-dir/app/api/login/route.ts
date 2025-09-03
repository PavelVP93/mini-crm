import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  const { username, password } = await request.json();
  if (username === 'admin' && password === 'admin') {
    const res = NextResponse.json({ ok: true });
    res.cookies.set('token', 'demo-token', { httpOnly: true, path: '/' });
    return res;
  }
  return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
}
