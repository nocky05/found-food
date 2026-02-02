-- Ajout des colonnes pour les préférences utilisateur si elles n'existent pas
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='is_dark_mode') THEN
        ALTER TABLE profiles ADD COLUMN is_dark_mode BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='notifications_enabled') THEN
        ALTER TABLE profiles ADD COLUMN notifications_enabled BOOLEAN DEFAULT TRUE;
    END IF;
END $$;

-- Mise à jour des politiques RLS si nécessaire (normalement update est déjà permis pour l'utilisateur sur son propre profil)
-- ALTER POLICY "Users can update own profile" ON profiles 
-- USING (auth.uid() = id)
-- WITH CHECK (auth.uid() = id);
