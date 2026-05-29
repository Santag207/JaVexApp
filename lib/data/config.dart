// ============================================================
// CONFIGURACIÓN DE SUPABASE
// ============================================================
// Obtén estos valores en: Supabase → Project Settings → API
//  - url: el "Project URL" base, SIN /rest/v1/ (el SDK la añade solo).
//  - anonKey: la clave "anon public" (empieza con "eyJ...").
// La anon key es pública por diseño, por lo que es válido incluirla
// en el cliente. NUNCA pongas aquí la clave "service_role".
// ============================================================

class SupabaseConfig {
  static const String url = 'https://vnvcypgipjtecfmhrqlq.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZudmN5cGdpcGp0ZWNmbWhycWxxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk1Nzg0NDUsImV4cCI6MjA5NTE1NDQ0NX0.uuw4SfvMGjVWhONcKjFiWIsvD8cJfl1BXA_t5RulWAI';
}
