--db:test
--{{{
\c postgres
drop database test;
create database test;
\c test
CREATE EXTENSION "uuid-ossp";

create type HumanName as (
  use varchar(256),
  family varchar(256)[],
  given varchar(256)[]
);

create type CodableConcept as (
  text text
);

create type PatientDeceased as (
  value_type varchar(256),
  value_datatime time,
  value_boolean time
);

create table patients (
  id uuid PRIMARY KEY default uuid_generate_v4(),
  deceased PatientDeceased,
  bith_date time,
  marital_status CodableConcept
);

create table patient_marital_status_codings (
  id uuid PRIMARY KEY default uuid_generate_v4(),
  patient_id uuid references patients(id),
  system varchar,
  code varchar,
  display varchar
);

-- complex type
create table patient_identifiers (
  id uuid PRIMARY KEY default uuid_generate_v4(),
  patient_id uuid references patients(id),
  use varchar,
  label varchar,
  system varchar,
  value varchar
);

-- complex type
create table patient_names (
  id uuid PRIMARY KEY default uuid_generate_v4(),
  patient_id uuid references patients(id),
  use varchar,
  family varchar[],
  given varchar[]
);


-- nested type
create table patient_contacts (
  id uuid PRIMARY KEY default uuid_generate_v4(),
  patient_id uuid references patients(id),
  name HumanName
);

create table patient_contact_relationships (
  id uuid PRIMARY KEY default uuid_generate_v4(),
  patient_id uuid references patients(id),
  text text
);

create table patient_contact_relationship_codings (
  id uuid PRIMARY KEY default uuid_generate_v4(),
  patient_id uuid references patients(id),
  relationship_id uuid references patient_contact_relationships(id),
  system varchar,
  code varchar,
  display varchar
);
--}}}
