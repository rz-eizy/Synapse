const API_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:8080/api';

export const getToken = () => localStorage.getItem('token');
export const setToken = (token: string) => localStorage.setItem('token', token);
export const removeToken = () => localStorage.removeItem('token');

async function fetchWithAuth(endpoint: string, options: RequestInit = {}) {
  const token = getToken();
  const headers = new Headers(options.headers || {});

  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  if (!headers.has('Content-Type') && !(options.body instanceof FormData)) {
    headers.set('Content-Type', 'application/json');
  }

  const response = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    if (response.status === 401 && !endpoint.includes('/auth/login')) {
      removeToken();
      window.location.reload(); // Force reload to trigger login screen
    }
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.error || errorData.message || 'Error al conectar con la API');
  }

  // Some endpoints might return empty body on success (like DELETE or some PATCH)
  const text = await response.text();
  return text ? JSON.parse(text) : null;
}

// Auth
export async function login(email: string, password: string) {
  const data = await fetchWithAuth('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
  if (data.token) {
    setToken(data.token);
  }
  return data;
}

// Moderation API

// Returns a Page<Publication> object from Spring Boot which looks like { content: [...], totalElements: 10, ... }
export async function getPosts(status?: string) {
  const params = new URLSearchParams();
  if (status && status !== 'all') params.append('status', status.toUpperCase());
  
  return fetchWithAuth(`/admin/posts?${params.toString()}`);
}

export async function moderatePost(id: string, action: 'APPROVED' | 'REJECTED', reason?: string) {
  return fetchWithAuth(`/admin/posts/${id}/moderate`, {
    method: 'PATCH',
    body: JSON.stringify({ status: action, reason }),
  });
}

export async function getPostReports(id: string) {
  return fetchWithAuth(`/admin/posts/${id}/reports`);
}

// Returns a Page<Comment>
export async function getComments(status?: string) {
  const params = new URLSearchParams();
  if (status && status !== 'all') params.append('status', status.toUpperCase());
  
  return fetchWithAuth(`/admin/comments?${params.toString()}`);
}

export async function moderateComment(id: string, action: 'APPROVED' | 'REJECTED', reason?: string) {
  return fetchWithAuth(`/admin/comments/${id}/moderate`, {
    method: 'PATCH',
    body: JSON.stringify({ status: action, reason }),
  });
}

export async function getCommentReports(id: string) {
  return fetchWithAuth(`/admin/comments/${id}/reports`);
}

export async function getDashboardStats() {
  return fetchWithAuth(`/admin/dashboard/stats`);
}

// Professional Requests
export async function getProfessionalRequests(page: number = 0, size: number = 20) {
  return fetchWithAuth(`/professional/requests?page=${page}&size=${size}`);
}

export async function approveProfessionalRequest(id: string, professionName: string) {
  return fetchWithAuth(`/professional/requests/${id}/approve?professionName=${encodeURIComponent(professionName)}`, {
    method: 'PATCH',
  });
}

export async function rejectProfessionalRequest(id: string, notes: string) {
  return fetchWithAuth(`/professional/requests/${id}/reject?notes=${encodeURIComponent(notes)}`, {
    method: 'PATCH',
  });
}
