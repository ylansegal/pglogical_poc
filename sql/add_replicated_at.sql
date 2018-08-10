ALTER TABLE widgets
    ADD COLUMN replicated_at timestamp without time zone DEFAULT NOW();
