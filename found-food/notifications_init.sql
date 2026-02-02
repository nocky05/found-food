-- ==========================================
-- TABLE DES NOTIFICATIONS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL, -- Destinataire
  actor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL, -- Celui qui fait l'action
  type TEXT NOT NULL CHECK (type IN ('like', 'comment', 'follow')),
  entity_id UUID, -- ID du post (pour like/comment) ou null (pour follow)
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Les utilisateurs voient leurs propres notifications" 
  ON public.notifications FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Les triggers peuvent insérer des notifications" 
  ON public.notifications FOR INSERT 
  WITH CHECK (true); -- Securisé par le fait que seuls les triggers/serveur insèrent généralement, ou via RLS validation si besoin

CREATE POLICY "Les utilisateurs peuvent marquer comme lu" 
  ON public.notifications FOR UPDATE 
  USING (auth.uid() = user_id);

-- ==========================================
-- TRIGGERS POUR AUTOMATISER LES NOTIFS
-- ==========================================

-- 1. Trigger pour LIKE
CREATE OR REPLACE FUNCTION public.handle_new_like()
RETURNS TRIGGER AS $$
BEGIN
  -- On ne se notifie pas soi-même
  IF NEW.user_id != (SELECT author_id FROM public.posts WHERE id = NEW.post_id) THEN
    INSERT INTO public.notifications (user_id, actor_id, type, entity_id)
    VALUES (
      (SELECT author_id FROM public.posts WHERE id = NEW.post_id), -- Auteur du post
      NEW.user_id, -- Celui qui like
      'like',
      NEW.post_id
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_like_created ON public.likes;
CREATE TRIGGER on_like_created
  AFTER INSERT ON public.likes
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_like();

-- 2. Trigger pour COMMENT
CREATE OR REPLACE FUNCTION public.handle_new_comment()
RETURNS TRIGGER AS $$
BEGIN
  -- On ne se notifie pas soi-même
  IF NEW.user_id != (SELECT author_id FROM public.posts WHERE id = NEW.post_id) THEN
    INSERT INTO public.notifications (user_id, actor_id, type, entity_id)
    VALUES (
      (SELECT author_id FROM public.posts WHERE id = NEW.post_id), -- Auteur du post
      NEW.user_id, -- Celui qui commente
      'comment',
      NEW.post_id
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_comment_created ON public.comments;
CREATE TRIGGER on_comment_created
  AFTER INSERT ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_comment();

-- 3. Trigger pour FOLLOW
CREATE OR REPLACE FUNCTION public.handle_new_follow()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.notifications (user_id, actor_id, type, entity_id)
  VALUES (
    NEW.following_id, -- Celui qui est suivi
    NEW.follower_id, -- Celui qui suit
    'follow',
    NULL
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_follow_created ON public.follows;
CREATE TRIGGER on_follow_created
  AFTER INSERT ON public.follows
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_follow();
