DROP TABLE IF EXISTS AUTH_SESSION;
DROP TABLE IF EXISTS AUTH_USER;
DROP TABLE IF EXISTS AUTH_ROLE;

CREATE TABLE IF NOT EXISTS auth_role(
  id INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  name VARCHAR(60) NOT NULL,
  CONSTRAINT pk_id_auth_role PRIMARY KEY(id),
  CONSTRAINT unique_name_auth_role UNIQUE(name)
);

CREATE TABLE IF NOT EXISTS auth_user (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60),
  password VARCHAR(250) NOT NULL,
  email VARCHAR(90) UNIQUE NOT NULL,
  email_verified TIMESTAMPTZ,
  image TEXT,
  phone VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMPTZ DEFAULT NOW(),
  role_id INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT pk_id_auth_user PRIMARY KEY(id),
  CONSTRAINT uk_email_auth_user UNIQUE(email),
  CONSTRAINT uk_phone_auth_user UNIQUE(phone),
  CONSTRAINT fk_role_id_auth_user FOREIGN KEY(role_id) REFERENCES AUTH_ROLE(id)
);

CREATE TABLE IF NOT EXISTS auth_session(
  id UUID DEFAULT GEN_RANDOM_UUID() NOT NULL,
  token TEXT NOT NULL,
  user_id UUID NOT NULL,
  expires TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  CONSTRAINT pk_id_auth_session PRIMARY KEY(id),
  CONSTRAINT unique_token_auth_session UNIQUE(token),
  CONSTRAINT fk_user_id_auth_session FOREIGN KEY(user_id) REFERENCES AUTH_USER(id)
);

CREATE OR REPLACE FUNCTION update_timestamp_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_user_on_change
BEFORE UPDATE ON auth_user
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp_updated_at();

INSERT INTO AUTH_ROLE(NAME) VALUES('user'), ('admin');