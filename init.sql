
-- Aqui vemos si los enums existen o no antes de crearlos
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('regular', 'professional', 'admin');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'validation_status') THEN
        CREATE TYPE validation_status AS ENUM ('pending', 'approved', 'rejected');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL, -- RNF-03 [cite: 36]
    full_name VARCHAR(255) NOT NULL,
    role user_role DEFAULT 'regular' NOT NULL, -- RF-01 [cite: 6]
    profile_picture_url TEXT, -- RF-20 [cite: 25]
    region VARCHAR(100), -- RF-12 [cite: 17]
    is_blocked BOOLEAN DEFAULT FALSE, -- RF-11 [cite: 16]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_sensitive_data (
    user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    child_diagnosis_encrypted TEXT, -- RNF-03 [cite: 36]
    id_card_front_url TEXT, -- RF-02 [cite: 7]
    id_card_back_url TEXT, -- RF-02 [cite: 7]
    identity_status validation_status DEFAULT 'pending', -- RF-02 [cite: 7]
    opt_in_marketing BOOLEAN DEFAULT FALSE -- RNF-04 [cite: 37]
);

CREATE TABLE IF NOT EXISTS professional_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    official_title VARCHAR(255),
    university_of_degree VARCHAR(255), -- RF-21 [cite: 29]
    years_experience INTEGER, -- RF-21 [cite: 29]
    session_price NUMERIC(10, 2), -- RF-22 [cite: 30]
    health_registry_id VARCHAR(50), -- RF-03 [cite: 8]
    is_accredited BOOLEAN DEFAULT FALSE, -- RF-03 [cite: 8]
    external_contact_link TEXT -- RF-08, RF-23 [cite: 13, 31]
);

CREATE TABLE IF NOT EXISTS posts (
    post_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL, -- RF-04 [cite: 9]
    image_url TEXT, -- RF-05 [cite: 10]
    region_tag VARCHAR(100), -- RF-12 [cite: 17]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS comments (
    comment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES posts(post_id) ON DELETE CASCADE,
    author_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL, -- RF-06 [cite: 11]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS favorites (
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    favorite_user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, favorite_user_id) -- RF-07 
);

CREATE TABLE IF NOT EXISTS professional_ratings (
    rating_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    professional_id UUID REFERENCES professional_profiles(user_id) ON DELETE CASCADE,
    stars INTEGER CHECK (stars >= 1 AND stars <= 5), -- RF-14 [cite: 19]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reports (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    reported_post_id UUID REFERENCES posts(post_id) ON DELETE SET NULL,
    reported_comment_id UUID REFERENCES comments(comment_id) ON DELETE SET NULL,
    reason TEXT, -- RF-09 [cite: 14]
    is_reviewed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Para probar que se autentique, la clave de cada usuario es: admin
INSERT INTO users (full_name, email, password_hash, role, region)
VALUES ('Eloy Prado', 'e.prado02@ufromail.cl', '$2a$10$erhFX6pgiS7js5qzIwuypOU3yRvmBbRkS.WfuExXuhlF5KExVxtoC', 'admin', 'Araucanía');

INSERT INTO users (full_name, email, password_hash, role, region)
VALUES ('Alesandro Duarte', 'a.duarte02@ufromail.cl', '$2a$10$erhFX6pgiS7js5qzIwuypOU3yRvmBbRkS.WfuExXuhlF5KExVxtoC', 'admin', 'Araucanía');

INSERT INTO users (full_name, email, password_hash, role, region)
VALUES ('Joaquín Sobarzo', 'j.sobarzo03@ufromail.cl', '$2a$10$erhFX6pgiS7js5qzIwuypOU3yRvmBbRkS.WfuExXuhlF5KExVxtoC', 'admin', 'Araucanía');