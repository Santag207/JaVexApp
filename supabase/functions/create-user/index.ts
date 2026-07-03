
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Método no permitido." }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // 1) Identificar al llamador a partir de su token.
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader) {
    return json({ error: "Falta el token de autorización." }, 401);
  }

  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: caller, error: callerErr } = await callerClient.auth.getUser();
  if (callerErr || !caller?.user) {
    return json({ error: "Sesión inválida." }, 401);
  }

  // 2) Cliente admin (service_role) para verificar rol y crear el usuario.
  const admin = createClient(supabaseUrl, serviceKey);

  const { data: callerProfile, error: profileErr } = await admin
    .from("users")
    .select("role")
    .eq("auth_id", caller.user.id)
    .maybeSingle();

  if (profileErr) {
    return json({ error: "No se pudo verificar el rol." }, 500);
  }
  if (!callerProfile || callerProfile.role !== "superuser") {
    return json({ error: "No tienes permisos para crear usuarios." }, 403);
  }

  // 3) Leer y validar el cuerpo.
  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Cuerpo inválido." }, 400);
  }

  const email = String(body.email ?? "").trim();
  const password = String(body.password ?? "");
  const nombre = String(body.nombre ?? "").trim();
  const apellidos = String(body.apellidos ?? "").trim();

  if (!email || !password) {
    return json({ error: "Email y contraseña son obligatorios." }, 400);
  }

  // 4) Crear el usuario en Auth.
  const { data: created, error: createErr } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
  });

  if (createErr || !created?.user) {
    return json(
      { error: createErr?.message ?? "No se pudo crear la cuenta." },
      400,
    );
  }

  const newAuthId = created.user.id;

  // 5) Crear el perfil en la tabla `users`. Si falla, revertir la cuenta Auth.
  const { error: insertErr } = await admin.from("users").insert({
    email,
    nombre,
    apellidos,
    auth_id: newAuthId,
    role: "normal",
  });

  if (insertErr) {
    await admin.auth.admin.deleteUser(newAuthId);
    return json(
      { error: "No se pudo crear el perfil: " + insertErr.message },
      400,
    );
  }

  return json({ ok: true, auth_id: newAuthId });
});
