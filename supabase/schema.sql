-- ============================================================
-- KFamily Charity DB Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- PROFILES (extends auth.users)
CREATE TABLE public.profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT NOT NULL,
  phone         TEXT,
  avatar_url    TEXT,
  role          TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  member_number INT  UNIQUE NOT NULL CHECK (member_number BETWEEN 1 AND 15),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_read_own" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "admins_read_all_profiles" ON public.profiles
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "admins_insert_profiles" ON public.profiles
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "admins_update_profiles" ON public.profiles
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "members_update_own_profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, member_number)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE((NEW.raw_user_meta_data->>'member_number')::INT, 0)
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- PAYMENT CYCLES (one per calendar month)
-- ============================================================
CREATE TABLE public.payment_cycles (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  year        INT NOT NULL,
  month       INT NOT NULL CHECK (month BETWEEN 1 AND 12),
  status      TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
  created_by  UUID REFERENCES public.profiles(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  closed_at   TIMESTAMPTZ,
  UNIQUE(year, month)
);

ALTER TABLE public.payment_cycles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "all_read_cycles" ON public.payment_cycles
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "admins_manage_cycles" ON public.payment_cycles
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- PAYMENT CONTRIBUTIONS (one per member per cycle)
-- ============================================================
CREATE TABLE public.payment_contributions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cycle_id         UUID NOT NULL REFERENCES public.payment_cycles(id) ON DELETE CASCADE,
  member_id        UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount           NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  status           TEXT NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending','submitted','approved','rejected')),
  screenshot_url   TEXT,
  screenshot_path  TEXT,
  submitted_at     TIMESTAMPTZ,
  reviewed_at      TIMESTAMPTZ,
  reviewed_by      UUID REFERENCES public.profiles(id),
  rejection_reason TEXT,
  notes            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(cycle_id, member_id)
);

ALTER TABLE public.payment_contributions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "members_read_own_contributions" ON public.payment_contributions
  FOR SELECT USING (auth.uid() = member_id);

CREATE POLICY "admins_read_all_contributions" ON public.payment_contributions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "members_insert_own_contribution" ON public.payment_contributions
  FOR INSERT WITH CHECK (auth.uid() = member_id);

CREATE POLICY "members_update_own_pending" ON public.payment_contributions
  FOR UPDATE USING (auth.uid() = member_id AND status IN ('pending', 'rejected'));

CREATE POLICY "admins_update_all_contributions" ON public.payment_contributions
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE public.notifications (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient  UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT NOT NULL,
  type       TEXT NOT NULL,
  payload    JSONB,
  is_read    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = recipient);

CREATE POLICY "users_update_own_notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = recipient);

CREATE POLICY "admins_insert_notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    OR auth.uid() = recipient
  );

-- ============================================================
-- VIEWS
-- ============================================================

CREATE OR REPLACE VIEW public.v_monthly_summary AS
SELECT
  pc.id AS cycle_id,
  pc.year,
  pc.month,
  pc.status,
  COUNT(pcon.id) FILTER (WHERE pcon.status = 'approved')                          AS paid_count,
  COUNT(pcon.id) FILTER (WHERE pcon.status IN ('pending','submitted'))             AS pending_count,
  COUNT(pcon.id) FILTER (WHERE pcon.status = 'rejected')                          AS rejected_count,
  COALESCE(SUM(pcon.amount) FILTER (WHERE pcon.status = 'approved'), 0)           AS total_collected,
  COUNT(DISTINCT pcon.member_id)                                                   AS total_members
FROM public.payment_cycles pc
LEFT JOIN public.payment_contributions pcon ON pcon.cycle_id = pc.id
GROUP BY pc.id, pc.year, pc.month, pc.status;

CREATE OR REPLACE VIEW public.v_member_yearly_summary AS
SELECT
  p.id AS member_id,
  p.full_name,
  p.member_number,
  pc.year,
  COUNT(pcon.id) FILTER (WHERE pcon.status = 'approved')             AS months_paid,
  COUNT(pcon.id) FILTER (WHERE pcon.status IN ('pending','submitted')) AS months_pending,
  COALESCE(SUM(pcon.amount) FILTER (WHERE pcon.status = 'approved'), 0) AS total_paid
FROM public.profiles p
CROSS JOIN (SELECT DISTINCT year FROM public.payment_cycles) pc
LEFT JOIN public.payment_contributions pcon
  ON pcon.member_id = p.id
  AND pcon.cycle_id IN (SELECT id FROM public.payment_cycles WHERE year = pc.year)
WHERE p.is_active = TRUE
GROUP BY p.id, p.full_name, p.member_number, pc.year;

-- ============================================================
-- STORAGE BUCKET
-- Run separately in Supabase Dashboard → Storage → New bucket
-- Name: payment-screenshots
-- Public: false
-- ============================================================
