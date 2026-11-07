-- Add the reservation state to the existing room status constraint.
alter table public.rooms
  drop constraint if exists rooms_status_check;

alter table public.rooms
  add constraint rooms_status_check
  check (status in ('AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'BOOKED'));
