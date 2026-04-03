CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "Users" (
    "UserID" SERIAL PRIMARY KEY,
    "UserName" VARCHAR(50) NOT NULL UNIQUE,
    "Email" VARCHAR(100) NOT NULL UNIQUE,
    "Password" TEXT NOT NULL
);

INSERT INTO "Users" ("UserName", "Email", "Password")
VALUES ('Eloy', 'e.prado02@ufromail.cl', crypt('admin', gen_salt('bf')));
INSERT INTO "Users" ("UserName", "Email", "Password")
VALUES ('Alesandro', 'a.duarte02@ufromail.cl', crypt('admin', gen_salt('bf')));
INSERT INTO "Users" ("UserName", "Email", "Password")
VALUES ('Joaquin', 'j.sobarzo03@ufromail.cl', crypt('admin', gen_salt('bf')));