// middleware.js
export function middleware(request) {
  // Protect admin routes
  if (request.nextUrl.pathname.startsWith('/admin')) {
    const authHeader = request.headers.get('authorization');
    
    if (!authHeader) {
      return new Response('Unauthorized', {
        status: 401,
        headers: { 'WWW-Authenticate': 'Basic' }
      });
    }
    
    // Check credentials
    const base64 = authHeader.split(' ')[1];
    const [user, pwd] = atob(base64).split(':');
    
    if (user !== 'admin' || pwd !== 'your-password') {
      return new Response('Unauthorized', { status: 401 });
    }
  }
}
