import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  if (pathname.startsWith('/api')) {
    return NextResponse.next();
  }

  const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/me`, {
    headers: { cookie: req.headers.get('cookie') ?? '' },
    credentials: 'include',
  }).catch(() => null);

  if (!res || !res.ok) {
    const response = NextResponse.redirect(new URL('/login', req.url));
    response.cookies.delete('token');
    return response;
  }

  if (pathname === '/login') {
    return NextResponse.redirect(new URL('/', req.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
