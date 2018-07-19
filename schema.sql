CREATE EXTENSION IF NOT EXISTS  pglogical; -- On all nodesz
-- CREATE EXTENSION pglogical_origin; -- Only needed for PostgreSQL 9.4

CREATE TABLE widgets (
    id bigint NOT NULL,
    name text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE widgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE widgets_id_seq OWNED BY widgets.id;

ALTER TABLE ONLY widgets ALTER COLUMN id SET DEFAULT nextval('widgets_id_seq'::regclass);

ALTER TABLE ONLY widgets
    ADD CONSTRAINT widgets_pkey PRIMARY KEY (id);
