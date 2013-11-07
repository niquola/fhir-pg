-- db:test
--{{{
drop schema if exists fhir cascade;
create schema fhir;
CREATE TYPE fhir.narrative_status AS ENUM ('additional','empty','extensions','generated');

CREATE TYPE fhir.quantity_compararator AS ENUM ('<','<=','>','>=');

CREATE TYPE fhir.identifier_use AS ENUM ('official','secondary','temp','usual');

CREATE TYPE fhir.event_timing AS ENUM ('AC','ACD','ACM','ACV','HS','PC','PCD','PCM','PCV','WAKE');

CREATE TYPE fhir.units_of_time AS ENUM ('a','d','h','min','mo','s','wk');

CREATE TYPE fhir.contact_system AS ENUM ('email','fax','phone','url');

CREATE TYPE fhir.contact_use AS ENUM ('home','mobile','old','temp','work');

CREATE TYPE fhir.address_use AS ENUM ('home','old','temp','work');

CREATE TYPE fhir.name_use AS ENUM ('anonymous','maiden','nickname','official','old','temp','usual');

CREATE TYPE fhir.document_reference_status AS ENUM ('current','error','superceded');

CREATE TYPE fhir.observation_status AS ENUM ('amended','cancelled','final','interim','registered','withdrawn');

CREATE TYPE fhir.value_set_status AS ENUM ('active','draft','retired');

create type fhir.resource_reference AS (
  reference uuid,
  display varchar
);

CREATE TYPE fhir.quantity AS (
  "value" varchar,
  "comparator" fhir.quantity_compararator,
  "units" varchar,
  "system" varchar,
  "code" varchar
);

CREATE TYPE fhir.element AS (

);
CREATE TYPE fhir.backbone_element AS (

);
CREATE TYPE fhir.resource_inline AS (

);
CREATE TYPE fhir.narrative AS (
"status" fhir.narrative_status
);
CREATE TYPE fhir.period AS (
"start" varchar,
"end" varchar
);
CREATE TYPE fhir.coding AS (
"system" varchar,
"version" varchar,
"code" varchar,
"display" varchar,
"primary" varchar
);
CREATE TYPE fhir.range AS (

);
CREATE TYPE fhir.attachment AS (
"content_type" varchar,
"language" varchar,
"data" varchar,
"url" varchar,
"size" varchar,
"hash" varchar,
"title" varchar
);
CREATE TYPE fhir.ratio AS (

);
CREATE TYPE fhir.sampled_data AS (
"period" varchar,
"factor" varchar,
"lower_limit" varchar,
"upper_limit" varchar,
"dimensions" varchar,
"data" varchar
);
CREATE TYPE fhir.codeable_concept AS (
"coding" fhir.coding[],
"text" varchar
);
CREATE TYPE fhir.identifier AS (
"use" fhir.identifier_use,
"label" varchar,
"system" varchar,
"value" varchar,
"period" fhir.period
);
CREATE TYPE fhir.age AS (
"value" varchar,
"units" varchar,
"system" varchar,
"code" varchar
);
CREATE TYPE fhir.count AS (
"value" varchar,
"units" varchar,
"system" varchar,
"code" varchar
);
CREATE TYPE fhir.money AS (
"value" varchar,
"units" varchar,
"system" varchar,
"code" varchar
);
CREATE TYPE fhir.distance AS (
"value" varchar,
"units" varchar,
"system" varchar,
"code" varchar
);
CREATE TYPE fhir.duration AS (
"value" varchar,
"units" varchar,
"system" varchar,
"code" varchar
);
CREATE TYPE fhir.schedule_repeat AS (
"frequency" varchar,
"when" fhir.event_timing,
"duration" varchar,
"units" fhir.units_of_time,
"count" varchar,
"end" varchar
);
CREATE TYPE fhir.schedule AS (
"event" fhir.period[],
"repeat" fhir.schedule_repeat
);
CREATE TYPE fhir.contact AS (
"system" fhir.contact_system,
"value" varchar,
"use" fhir.contact_use,
"period" fhir.period
);
CREATE TYPE fhir.address AS (
"use" fhir.address_use,
"text" varchar,
"line" varchar[],
"city" varchar,
"state" varchar,
"zip" varchar,
"country" varchar,
"period" fhir.period
);
CREATE TYPE fhir.human_name AS (
"use" fhir.name_use,
"text" varchar,
"family" varchar[],
"given" varchar[],
"prefix" varchar[],
"suffix" varchar[],
"period" fhir.period
);
--}}}