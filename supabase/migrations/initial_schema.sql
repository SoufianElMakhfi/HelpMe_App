-- Initial Schema for HelpMe App
-- Run this in Supabase SQL Editor

-- Create profiles table
create table public.profiles (
  id uuid references auth.users not null primary key,
  role text check (role in ('customer', 'craftsman')),
  full_name text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.profiles enable row level security;

-- Policies
create policy "Public profiles are viewable by everyone." 
  on public.profiles for select using (true);

create policy "Users can insert their own profile." 
  on public.profiles for insert with check (auth.uid() = id);

create policy "Users can update own profile." 
  on public.profiles for update using (auth.uid() = id);
