-- ==========================================
-- SYSTÈME DE STORIES - SETUP
-- ==========================================

-- 1. Table des Stories
CREATE TABLE IF NOT EXISTS public.stories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  media_url TEXT NOT NULL,
  media_type TEXT DEFAULT 'image', -- 'image' or 'video'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours')
);

-- Active RLS
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

-- Index pour la performance
CREATE INDEX IF NOT EXISTS idx_stories_expires_at ON public.stories (expires_at);

-- 2. Politiques RLS (Idempotent)
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

-- 3. Vue pour les stories actives
-- Cette vue joint les profils pour avoir le nom et l'avatar directement
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
ORDER BY s.created_at ASC;

-- 4. Configuration du stockage pour les stories
-- Note: Assurez-vous d'avoir un bucket nommé 'stories' dans Supabase Storage
DO $$
BEGIN
  -- Lecture publique
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Lecture publique des stories'
  ) THEN
    CREATE POLICY "Lecture publique des stories" ON storage.objects FOR SELECT USING (bucket_id = 'stories');
  END IF;

  -- Upload par les membres connectés
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
