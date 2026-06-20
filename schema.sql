-- ============================================
-- Suhbat (Talkio) — Database Schema
-- Run this in Supabase SQL Editor to set up all tables, RLS policies, and triggers
-- ============================================

-- ============================================
-- TABLES
-- ============================================

-- Profiles table
create table public.profiles (
  id uuid not null,
  username text not null,
  avatar_url text null,
  created_at timestamp with time zone null default timezone ('utc'::text, now()),
  constraint profiles_pkey primary key (id),
  constraint profiles_username_key unique (username),
  constraint profiles_id_fkey foreign key (id) references auth.users (id) on delete cascade
);

-- Rooms table
create table public.rooms (
  id uuid not null default gen_random_uuid (),
  name text not null,
  created_at timestamp with time zone null default timezone ('utc'::text, now()),
  constraint rooms_pkey primary key (id)
);

-- Messages table (group chat)
create table public.messages (
  id uuid not null default gen_random_uuid (),
  room_id uuid null,
  user_id uuid null,
  content text not null,
  created_at timestamp with time zone null default timezone ('utc'::text, now()),
  is_read boolean null default false,
  constraint messages_pkey primary key (id),
  constraint messages_room_id_fkey foreign key (room_id) references rooms (id) on delete cascade,
  constraint messages_user_id_fkey foreign key (user_id) references profiles (id) on delete cascade
);

-- Conversations table (for DMs)
create table public.conversations (
  id uuid not null default gen_random_uuid (),
  user1_id uuid null default gen_random_uuid (),
  user2_id uuid null default gen_random_uuid (),
  created_at timestamp with time zone not null default now(),
  constraint conversations_pkey primary key (id),
  constraint conversations_user1_id_fkey foreign key (user1_id) references profiles (id),
  constraint conversations_user2_id_fkey foreign key (user2_id) references profiles (id)
);

-- Direct messages table
create table public.direct_messages (
  id uuid not null default gen_random_uuid (),
  created_at timestamp with time zone not null default now(),
  conversation_id uuid null default gen_random_uuid (),
  sender_id uuid null default gen_random_uuid (),
  content text null,
  is_read boolean not null default false,
  constraint direct_messages_pkey primary key (id),
  constraint direct_messages_conversation_id_fkey foreign key (conversation_id) references conversations (id),
  constraint direct_messages_sender_id_fkey foreign key (sender_id) references profiles (id)
);

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================

alter table public.profiles enable row level security;
alter table public.rooms enable row level security;
alter table public.messages enable row level security;
alter table public.conversations enable row level security;
alter table public.direct_messages enable row level security;

-- ============================================
-- RLS POLICIES — profiles
-- ============================================

create policy "Public profiles are viewable by everyone"
on public.profiles
for select
to public
using (true);

create policy "Users can insert their own profile"
on public.profiles
for insert
to public
with check (auth.uid() = id);

create policy "Users can update their own profile"
on public.profiles
for update
to public
using (auth.uid() = id)
with check (auth.uid() = id);

-- ============================================
-- RLS POLICIES — rooms
-- ============================================

create policy "Rooms are viewable by everyone"
on public.rooms
for select
to public
using (true);

create policy "Authenticated users can create rooms"
on public.rooms
for insert
to public
with check (auth.uid() is not null);

-- ============================================
-- RLS POLICIES — messages
-- ============================================

create policy "Messages are viewable by everyone"
on public.messages
for select
to public
using (true);

create policy "Authenticated users can send messages"
on public.messages
for insert
to public
with check (auth.uid() = user_id);

create policy "Users can mark others' messages as read"
on public.messages
for update
to public
using (auth.uid() != user_id)
with check (auth.uid() != user_id);

-- ============================================
-- RLS POLICIES — conversations
-- ============================================

create policy "Users can view their own conversations"
on public.conversations
for select
to public
using (auth.uid() = user1_id or auth.uid() = user2_id);

create policy "Users can create conversations"
on public.conversations
for insert
to public
with check (auth.uid() = user1_id or auth.uid() = user2_id);

-- ============================================
-- RLS POLICIES — direct_messages
-- ============================================

create policy "Users can view their own direct messages"
on public.direct_messages
for select
to public
using (
  auth.uid() in (
    select conversations.user1_id from conversations where conversations.id = direct_messages.conversation_id
    union
    select conversations.user2_id from conversations where conversations.id = direct_messages.conversation_id
  )
);

create policy "Users can send direct messages"
on public.direct_messages
for insert
to public
with check (auth.uid() = sender_id);

create policy "Users can update read status of their direct messages"
on public.direct_messages
for update
to public
using (
  auth.uid() in (
    select conversations.user1_id from conversations where conversations.id = direct_messages.conversation_id
    union
    select conversations.user2_id from conversations where conversations.id = direct_messages.conversation_id
  )
)
with check (
  auth.uid() in (
    select conversations.user1_id from conversations where conversations.id = direct_messages.conversation_id
    union
    select conversations.user2_id from conversations where conversations.id = direct_messages.conversation_id
  )
);

-- ============================================
-- TRIGGER — auto-create profile on signup
-- ============================================

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================
-- ENABLE REALTIME
-- ============================================
-- After running this script, enable Realtime for these tables in:
-- Dashboard → Table Editor → [table name] → Realtime toggle → ON
--   - messages
--   - direct_messages
--   - conversations