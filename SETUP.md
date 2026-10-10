# Setup (once)

1. supabase.com -> New project (any name, pick a strong database password, nearest region).
2. Authentication -> Sign In / Providers (or Settings) -> turn OFF "Allow new users to sign up".
3. SQL Editor -> New query -> paste all of schema.sql -> Run.
4. Authentication -> Users -> Add user -> Create new user:
   email  admin@clients.example.com   password: a strong one   tick "Auto Confirm User".
5. SQL Editor -> run the last (commented) statement in schema.sql: remove the two leading dashes first.
6. Project Settings -> API: copy "Project URL" and the "anon public" key into config.js.
7. GitHub: upload everything in this folder (keep the api and videos folders).
8. Vercel -> import the repository -> Settings -> Environment Variables, add:
   SUPABASE_URL = the Project URL
   SUPABASE_SERVICE_ROLE_KEY = the "service_role" key (SECRET: only here, never in a file)
   Then Deployments -> Redeploy.
9. Open /app, log in with username "admin" and the password from step 4.
