-- db:test
--{{{
create table ups (
id uuid PRIMARY KEY default uuid_generate_v4(),
gender codeable_concept,
birth_date dateTime,
deceased patient_deceased,
marital_status codeable_concept,
multiple_birth patient_multiple_birth,
animal patient_animal,
active boolean
);
create table patient_identifiers (
id uuid PRIMARY KEY default uuid_generate_v4(),
use identifier_use,
label string,
system uri,
value string,
period period,
assigner resource_reference
);

create table patient_names (
id uuid PRIMARY KEY default uuid_generate_v4(),
use name_use,
text string,
period period
);
create table patient_name_families (
id uuid PRIMARY KEY default uuid_generate_v4(),

);

create table patient_name_givens (
id uuid PRIMARY KEY default uuid_generate_v4(),

);

create table patient_name_prefixes (
id uuid PRIMARY KEY default uuid_generate_v4(),

);

create table patient_name_suffixes (
id uuid PRIMARY KEY default uuid_generate_v4(),

);

create table patient_telecoms (
id uuid PRIMARY KEY default uuid_generate_v4(),
system contact_system,
value string,
use contact_use,
period period
);

create table patient_addresses (
id uuid PRIMARY KEY default uuid_generate_v4(),
use address_use,
text string,
city string,
state string,
zip string,
country string,
period period
);
create table patient_address_lines (
id uuid PRIMARY KEY default uuid_generate_v4(),

);

create table patient_photos (
id uuid PRIMARY KEY default uuid_generate_v4(),
contentType code,
language code,
data base64Binary,
url uri,
size integer,
hash base64Binary,
title string
);

create table patient_contacts (
id uuid PRIMARY KEY default uuid_generate_v4(),
name human_name,
address address,
gender codeable_concept
);
create table patient_contact_relationships (
id uuid PRIMARY KEY default uuid_generate_v4(),
text string
);
create table patient_contact_relationship_codings (
id uuid PRIMARY KEY default uuid_generate_v4(),

);

create table patient_contact_telecoms (
id uuid PRIMARY KEY default uuid_generate_v4(),
system contact_system,
value string,
use contact_use,
period period
);

create table patient_communications (
id uuid PRIMARY KEY default uuid_generate_v4(),
text string
);
create table patient_communication_codings (
id uuid PRIMARY KEY default uuid_generate_v4(),

);

create table patient_links (
id uuid PRIMARY KEY default uuid_generate_v4(),
type code
);

--}}}