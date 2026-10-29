-- Supabase migration version recorded by the connected project after apply_migration.
-- PII-free Latest LatePoint state + 24h/2h slot projection.
-- NEVER expose booking reminders through the client Data API.
BEGIN;

CREATE TABLE IF NOT EXISTS public.latepoint_booking_states (
  booking_id text PRIMARY KEY CHECK (booking_id ~ '^[1-9][0-9]{0,17}$'),
  latest_event_id uuid NOT NULL REFERENCES public.inbound_events(id),
  occurred_at timestamptz NOT NULL,
  status text NOT NULL CHECK (status IN ('approved','pending','cancelled','no_show','completed','deleted')),
  starts_at timestamptz,
  conflict boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT latepoint_booking_state_start CHECK ((status = 'deleted') = (starts_at IS NULL))
);

CREATE TABLE IF NOT EXISTS public.latepoint_reminder_slots (
  booking_id text NOT NULL REFERENCES public.latepoint_booking_states(booking_id) ON DELETE CASCADE,
  lead_hours smallint NOT NULL CHECK (lead_hours IN (24,2)),
  revision_event_id uuid NOT NULL REFERENCES public.inbound_events(id),
  starts_at timestamptz,
  due_at timestamptz,
  status text NOT NULL CHECK (status IN ('scheduled','invalidated','suppressed')),
  reason text NOT NULL CHECK (reason IN (
    'awaiting_due_time','not_approved','past_or_due','beyond_horizon',
    'conflicting_revision','outbound_not_authorized'
  )),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (booking_id,lead_hours),
  CONSTRAINT latepoint_scheduled_has_due CHECK (status <> 'scheduled' OR due_at IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_latepoint_reminder_slots_due
  ON public.latepoint_reminder_slots(due_at,booking_id,lead_hours)
  WHERE status='scheduled';

ALTER TABLE public.latepoint_booking_states ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.latepoint_reminder_slots ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.latepoint_booking_states, public.latepoint_reminder_slots
  FROM anon, authenticated;

COMMIT;
