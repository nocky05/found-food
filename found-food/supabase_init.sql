-- 1. Table des Profils (profiles)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'profiles' AND policyname = 'Les profils sont visibles par tous.') THEN
    CREATE POLICY "Les profils sont visibles par tous." ON profiles FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'profiles' AND policyname = 'Les utilisateurs peuvent modifier leur propre profil.') THEN
    CREATE POLICY "Les utilisateurs peuvent modifier leur propre profil." ON profiles FOR UPDATE USING ((SELECT auth.uid()) = id);
  END IF;
END $$;

-- 2. Table des Lieux (places)
CREATE TABLE IF NOT EXISTS places (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  phone TEXT,
  category TEXT,
  budget_range TEXT, -- €, €€, €€€
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on places
ALTER TABLE places ENABLE ROW LEVEL SECURITY;

-- Places Policies
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'places' AND policyname = 'Les lieux sont visibles par tous.') THEN
    CREATE POLICY "Les lieux sont visibles par tous." ON places FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'places' AND policyname = 'Les utilisateurs authentifiés peuvent ajouter un lieu.') THEN
    CREATE POLICY "Les utilisateurs authentifiés peuvent ajouter un lieu." ON places FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
END $$;

-- 3. Table des Publications (posts)
CREATE TABLE IF NOT EXISTS posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  author_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  place_id UUID REFERENCES places(id) ON DELETE CASCADE NOT NULL,
  content TEXT,
  budget_spent NUMERIC,
  trip_cost NUMERIC,
  trip_duration INTEGER,
  transport_mode TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on posts
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Posts Policies
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'posts' AND policyname = 'Les posts sont visibles par tous.') THEN
    CREATE POLICY "Les posts sont visibles par tous." ON posts FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'posts' AND policyname = 'Les utilisateurs authentifiés peuvent créer un post.') THEN
    CREATE POLICY "Les utilisateurs authentifiés peuvent créer un post." ON posts FOR INSERT WITH CHECK ((SELECT auth.uid()) = author_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'posts' AND policyname = 'Les auteurs peuvent supprimer leur propre post.') THEN
    CREATE POLICY "Les auteurs peuvent supprimer leur propre post." ON posts FOR DELETE USING ((SELECT auth.uid()) = author_id);
  END IF;
END $$;

-- 4. Table des Médias (post_media)
CREATE TABLE IF NOT EXISTS post_media (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL, -- 'image' or 'video'
  url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on post_media
ALTER TABLE post_media ENABLE ROW LEVEL SECURITY;

-- Post Media Policies
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'post_media' AND policyname = 'Les médias sont visibles par tous.') THEN
    CREATE POLICY "Les médias sont visibles par tous." ON post_media FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'post_media' AND policyname = 'Les auteurs peuvent ajouter des médias à leurs posts.') THEN
    CREATE POLICY "Les auteurs peuvent ajouter des médias à leurs posts." ON post_media FOR INSERT WITH CHECK (
      EXISTS (SELECT 1 FROM posts WHERE posts.id = post_id AND posts.author_id = (SELECT auth.uid()))
    );
  END IF;
END $$;

-- 5. Trigger (Handle existing function)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public, pg_catalog, pg_temp
AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, avatar_url)
  VALUES (
    NEW.id,
    LOWER(SPLIT_PART(NEW.email, '@', 1)) || '_' || SUBSTR(CAST(NEW.id AS TEXT), 1, 4),
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Trigger creation (Safe)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created') THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
  END IF;
END $$;

-- 7. Table des Likes (likes)
CREATE TABLE IF NOT EXISTS likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'likes' AND policyname = 'Les likes sont visibles par tous.') THEN
    CREATE POLICY "Les likes sont visibles par tous." ON likes FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'likes' AND policyname = 'Les utilisateurs authentifiés peuvent liker.') THEN
    CREATE POLICY "Les utilisateurs authentifiés peuvent liker." ON likes FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'likes' AND policyname = 'Les utilisateurs peuvent retirer leur like.') THEN
    CREATE POLICY "Les utilisateurs peuvent retirer leur like." ON likes FOR DELETE USING ((SELECT auth.uid()) = user_id);
  END IF;
END $$;

-- 8. Table des Commentaires (comments)
CREATE TABLE IF NOT EXISTS comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'comments' AND policyname = 'Les commentaires sont visibles par tous.') THEN
    CREATE POLICY "Les commentaires sont visibles par tous." ON comments FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'comments' AND policyname = 'Les utilisateurs authentifiés peuvent commenter.') THEN
    CREATE POLICY "Les utilisateurs authentifiés peuvent commenter." ON comments FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'comments' AND policyname = 'Les utilisateurs peuvent modifier/supprimer leurs commentaires.') THEN
    CREATE POLICY "Les utilisateurs peuvent modifier/supprimer leurs commentaires." ON comments FOR ALL USING ((SELECT auth.uid()) = user_id);
  END IF;
END $$;

-- 9. Table des Favoris (favorites)
CREATE TABLE IF NOT EXISTS favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'favorites' AND policyname = 'Les utilisateurs voient leurs propres favoris.') THEN
    CREATE POLICY "Les utilisateurs voient leurs propres favoris." ON favorites FOR SELECT USING ((SELECT auth.uid()) = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'favorites' AND policyname = 'Les utilisateurs peuvent ajouter des favoris.') THEN
    CREATE POLICY "Les utilisateurs peuvent ajouter des favoris." ON favorites FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'favorites' AND policyname = 'Les utilisateurs peuvent supprimer leurs favoris.') THEN
    CREATE POLICY "Les utilisateurs peuvent supprimer leurs favoris." ON favorites FOR DELETE USING ((SELECT auth.uid()) = user_id);
  END IF;
END $$;

-- ==========================================
-- 10. OPTIMISATIONS & VUES CONSOLIDÉES
-- ==========================================

-- Vue consolidée sécurisée (respecte les RLS des tables sous-jacentes)
CREATE OR REPLACE VIEW posts_with_stats 
WITH (security_invoker = true)
AS
SELECT 
  p.*,
  json_build_object(
    'username', pr.username,
    'full_name', pr.full_name,
    'avatar_url', pr.avatar_url
  ) as profiles,
  json_build_object(
    'name', pl.name,
    'address', pl.address,
    'category', pl.category
  ) as places,
  (SELECT count(*) FROM likes l WHERE l.post_id = p.id) as likes_count,
  (SELECT count(*) FROM comments c WHERE c.post_id = p.id) as comments_count,
  COALESCE((
    SELECT json_agg(json_build_object('url', pm.url, 'type', pm.type))
    FROM post_media pm 
    WHERE pm.post_id = p.id
  ), '[]'::json) as post_media
FROM posts p
LEFT JOIN profiles pr ON p.author_id = pr.id
LEFT JOIN places pl ON p.place_id = pl.id;

-- ==========================================
-- 11. FONCTIONS RPC (OPÉRATIONS ATOMIQUES)
-- ==========================================

-- Fonction pour Liker/Unliker de manière atomique
CREATE OR REPLACE FUNCTION public.toggle_like(target_post_id UUID)
RETURNS BOOLEAN 
LANGUAGE plpgsql
SET search_path = public, pg_catalog, pg_temp
AS $$
DECLARE
  current_user_id UUID := (SELECT auth.uid());
  already_liked BOOLEAN;
BEGIN
  SELECT EXISTS (SELECT 1 FROM public.likes WHERE post_id = target_post_id AND user_id = current_user_id) INTO already_liked;
  
  IF already_liked THEN
    DELETE FROM public.likes WHERE post_id = target_post_id AND user_id = current_user_id;
    RETURN FALSE;
  ELSE
    INSERT INTO public.likes (post_id, user_id) VALUES (target_post_id, current_user_id);
    RETURN TRUE;
  END IF;
END;
$$;

-- Fonction pour Favori/Défavori
CREATE OR REPLACE FUNCTION public.toggle_favorite(target_post_id UUID)
RETURNS BOOLEAN 
LANGUAGE plpgsql
SET search_path = public, pg_catalog, pg_temp
AS $$
DECLARE
  current_user_id UUID := (SELECT auth.uid());
  already_fav BOOLEAN;
BEGIN
  SELECT EXISTS (SELECT 1 FROM public.favorites WHERE post_id = target_post_id AND user_id = current_user_id) INTO already_fav;
  
  IF already_fav THEN
    DELETE FROM public.favorites WHERE post_id = target_post_id AND user_id = current_user_id;
    RETURN FALSE;
  ELSE
    INSERT INTO public.favorites (post_id, user_id) VALUES (target_post_id, current_user_id);
    RETURN TRUE;
  END IF;
END;
$$;

-- ==========================================
-- 12. CONFIGURATION DU STOCKAGE (POLICIES)
-- ==========================================
-- Note: Les buckets 'posts', 'profiles' et 'places' doivent être créés via le Dashboard Supabase.
-- Ces règles s'appliquent une fois les buckets créés.

BEGIN;
  -- Politiques pour les médias des posts (create only if missing)
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Lecture publique des médias'
    ) THEN
      CREATE POLICY "Lecture publique des médias" ON storage.objects FOR SELECT USING (bucket_id = 'posts');
    END IF;
  END$$;

  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Upload des médias par les auteurs'
    ) THEN
      CREATE POLICY "Upload des médias par les auteurs" ON storage.objects FOR INSERT WITH CHECK (
        bucket_id = 'posts' AND auth.role() = 'authenticated'
      );
    END IF;
  END$$;

  -- Politiques pour les avatars
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Lecture publique des avatars'
    ) THEN
      CREATE POLICY "Lecture publique des avatars" ON storage.objects FOR SELECT USING (bucket_id = 'profiles');
    END IF;
  END$$;

  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Upload propre avatar'
    ) THEN
      CREATE POLICY "Upload propre avatar" ON storage.objects FOR INSERT WITH CHECK (
        bucket_id = 'profiles' AND (SELECT auth.uid())::text = (storage.foldername(name))[1]
      );
    END IF;
  END$$;
COMMIT;

-- ==========================================
-- 13. RECHERCHE FULL-TEXT
-- ==========================================

-- Fonction de recherche pour les lieux
CREATE OR REPLACE FUNCTION public.search_places(query_text TEXT)
RETURNS SETOF public.places 
LANGUAGE plpgsql
SET search_path = public, pg_catalog, pg_temp
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.places
  WHERE 
    name ILIKE '%' || query_text || '%' OR 
    category ILIKE '%' || query_text || '%' OR
    address ILIKE '%' || query_text || '%';
END;
$$;

-- ==========================================
-- 14. SYSTÈME DE STORIES
-- ==========================================

-- Table des Stories
CREATE TABLE IF NOT EXISTS public.stories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  media_url TEXT NOT NULL,
  media_type TEXT DEFAULT 'image', -- 'image' or 'video'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours')
);

-- Enable RLS
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

-- Index pour la performance des requêtes basées sur le temps
CREATE INDEX IF NOT EXISTS idx_stories_expires_at ON public.stories (expires_at);

-- Policies
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'stories' AND policyname = 'Les stories sont visibles par tous.') THEN
    CREATE POLICY "Les stories sont visibles par tous." ON public.stories FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'stories' AND policyname = 'Les utilisateurs peuvent créer leurs propres stories.') THEN
    CREATE POLICY "Les utilisateurs peuvent créer leurs propres stories." ON public.stories FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'stories' AND policyname = 'Les utilisateurs peuvent supprimer leurs propres stories.') THEN
    CREATE POLICY "Les utilisateurs peuvent supprimer leurs propres stories." ON public.stories FOR DELETE USING ((SELECT auth.uid()) = user_id);
  END IF;
END $$;

-- Vue pour les stories actives (filtrées par date d'expiration)
CREATE OR REPLACE VIEW public.active_stories 
WITH (security_invoker = true)
AS
SELECT 
  s.*,
  pr.username,
  pr.full_name,
  pr.avatar_url
FROM public.stories s
JOIN public.profiles pr ON s.user_id = pr.id
WHERE s.expires_at > NOW()
ORDER BY s.created_at DESC;

-- Configuration du stockage pour les stories
-- Note: Le bucket 'stories' doit être créé manuellement ou via Supabase CLI
BEGIN;
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Lecture publique des stories'
    ) THEN
      CREATE POLICY "Lecture publique des stories" ON storage.objects FOR SELECT USING (bucket_id = 'stories');
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'storage'
        AND tablename = 'objects'
        AND policyname = 'Upload des stories par les utilisateurs'
    ) THEN
      CREATE POLICY "Upload des stories par les utilisateurs" ON storage.objects FOR INSERT WITH CHECK (
        bucket_id = 'stories' AND auth.role() = 'authenticated'
      );
    END IF;
  END$$;
COMMIT;
