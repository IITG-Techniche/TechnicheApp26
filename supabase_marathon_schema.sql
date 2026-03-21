-- Table 1: marathon_participants
CREATE TABLE IF NOT EXISTS marathon_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    username TEXT NOT NULL UNIQUE,
    pin TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('6K', '21K')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table 2: practice_logs
CREATE TABLE IF NOT EXISTS practice_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    username TEXT NOT NULL REFERENCES marathon_participants (username) ON DELETE CASCADE,
    distance_km NUMERIC NOT NULL,
    duration_minutes NUMERIC NOT NULL,
    avg_pace NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security (RLS) Policies
ALTER TABLE marathon_participants ENABLE ROW LEVEL SECURITY;

ALTER TABLE practice_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read marathon_participants" ON marathon_participants;

CREATE POLICY "Allow public read marathon_participants" ON marathon_participants FOR
SELECT USING (true);

DROP POLICY IF EXISTS "Allow public insert marathon_participants" ON marathon_participants;

CREATE POLICY "Allow public insert marathon_participants" ON marathon_participants FOR
INSERT
WITH
    CHECK (true);

DROP POLICY IF EXISTS "Allow public update marathon_participants" ON marathon_participants;

CREATE POLICY "Allow public update marathon_participants" ON marathon_participants FOR
UPDATE USING (true)
WITH
    CHECK (true);

DROP POLICY IF EXISTS "Allow public read practice_logs" ON practice_logs;

CREATE POLICY "Allow public read practice_logs" ON practice_logs FOR
SELECT USING (true);

DROP POLICY IF EXISTS "Allow public insert practice_logs" ON practice_logs;

CREATE POLICY "Allow public insert practice_logs" ON practice_logs FOR
INSERT
WITH
    CHECK (true);

DROP POLICY IF EXISTS "Allow public update practice_logs" ON practice_logs;

CREATE POLICY "Allow public update practice_logs" ON practice_logs FOR
UPDATE USING (true)
WITH
    CHECK (true);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_practice_logs_username ON practice_logs (username);

CREATE INDEX IF NOT EXISTS idx_practice_logs_created_at ON practice_logs (created_at);

-- View: Distance Leaderboard
DROP FUNCTION IF EXISTS get_distance_leaderboard(TEXT);

CREATE OR REPLACE VIEW distance_leaderboard AS
SELECT p.category, p.username, COALESCE(SUM(l.distance_km), 0) AS total_distance
FROM
    marathon_participants p
    LEFT JOIN practice_logs l ON p.username = l.username
GROUP BY
    p.category,
    p.username
ORDER BY COALESCE(SUM(l.distance_km), 0) DESC, p.username ASC;

-- RPC: Weekly Stats & Improvement
CREATE OR REPLACE FUNCTION get_user_progress(p_username TEXT)
RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
  v_streak INT := 0;
  v_weekly_km NUMERIC := 0;
  v_weekly_pace NUMERIC := 0;
  v_today_km NUMERIC := 0;
  v_yesterday_km NUMERIC := 0;
  v_improvement NUMERIC := 0;
  v_daily_stats jsonb;
BEGIN
  -- Calculate streak using Gaps and Islands approach
  WITH user_dates AS (
    SELECT DISTINCT DATE_TRUNC('day', created_at) AS run_date
    FROM practice_logs
    WHERE username = p_username
  ),
  date_groups AS (
    SELECT run_date,
           run_date - (ROW_NUMBER() OVER (ORDER BY run_date) * INTERVAL '1 day') AS grp
    FROM user_dates
  ),
  streak_counts AS (
    SELECT COUNT(*) AS streak_len, MAX(run_date) AS last_run_date
    FROM date_groups
    GROUP BY grp
  )
  SELECT streak_len
  INTO v_streak
  FROM streak_counts
  WHERE last_run_date >= CURRENT_DATE - INTERVAL '1 day'
  ORDER BY last_run_date DESC
  LIMIT 1;

  v_streak := COALESCE(v_streak, 0);
 
   -- Get this week's stats (Total across last 7 days)
   SELECT COALESCE(SUM(distance_km), 0),
          CASE WHEN SUM(distance_km) > 0 THEN SUM(duration_minutes) / SUM(distance_km) ELSE 0 END
   INTO v_weekly_km, v_weekly_pace
   FROM practice_logs
   WHERE username = p_username AND created_at >= NOW() - INTERVAL '7 days';
   
   -- Get today's and yesterday's distance to calculate daily improvement
   SELECT COALESCE(SUM(distance_km), 0)
   INTO v_today_km
   FROM practice_logs
   WHERE username = p_username AND DATE_TRUNC('day', created_at AT TIME ZONE 'Asia/Kolkata') = (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Kolkata')::date;

   SELECT COALESCE(SUM(distance_km), 0)
   INTO v_yesterday_km
   FROM practice_logs
   WHERE username = p_username AND DATE_TRUNC('day', created_at AT TIME ZONE 'Asia/Kolkata') = (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Kolkata')::date - INTERVAL '1 day';
 
   -- Calculate improvement %
   IF v_yesterday_km > 0 THEN
     v_improvement := ((v_today_km - v_yesterday_km) / v_yesterday_km) * 100;
   ELSIF v_today_km > 0 THEN
     v_improvement := 100; -- Ran today but not yesterday
   ELSE
     v_improvement := 0; -- No run today, no run yesterday
   END IF;
   
   -- Get daily stats for last 7 days
   -- Note: We use 'Asia/Kolkata' for local date context
   SELECT jsonb_agg(daily_data)
   INTO v_daily_stats
   FROM (
     WITH days AS (
       SELECT generate_series((CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Kolkata')::date - INTERVAL '6 days', (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Kolkata')::date, '1 day')::date AS d
     )
     SELECT 
       TO_CHAR(days.d, 'Dy') as day_name,
       COALESCE(SUM(l.distance_km), 0) as distance,
       CASE WHEN SUM(l.distance_km) > 0 THEN SUM(l.duration_minutes) / SUM(l.distance_km) ELSE 0 END as pace,
       (days.d = (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Kolkata')::date) as is_today
     FROM days
     LEFT JOIN practice_logs l ON DATE_TRUNC('day', l.created_at AT TIME ZONE 'Asia/Kolkata')::date = days.d AND l.username = p_username
     GROUP BY days.d
     ORDER BY days.d
   ) daily_data;
  
  RETURN jsonb_build_object(
    'streak', v_streak,
    'weekly_km', ROUND(v_weekly_km, 2),
    'weekly_pace', ROUND(v_weekly_pace, 2),
    'improvement', ROUND(v_improvement, 2),
    'daily_stats', v_daily_stats
  );
END;
$$;