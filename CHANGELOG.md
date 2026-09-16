# Changelog

All notable changes to this project will be documented in this file.

For more information about changelogs, check [Keep a Changelog](http://keepachangelog.com) and
[Vandamme](http://tech-angels.github.io/vandamme).

## [Unreleased]

## 0.4.0 - 2026-09-15

* [Breaking change] The models are `State`, `County`, `City`, `CityCounty` and `ZIP`, at the
  top level rather than under `USA::`. A host writes `belongs_to :zip` and Active Record finds
  the class, where before it refused anything but `class_name: 'USA::ZIP'` -- its `compute_type`
  wants a class whose own name is the one it asked for, so no alias or configuration could stand
  in. The `model_name` overrides that made the old classes answer as `ZIP` and `County` are gone
  with the namespace they were papering over
* [Breaking change] The tables are `states`, `counties`, `cities`, `city_counties` and `zips`.
  A host that wants them to itself sets `USA.table_name_prefix = 'usa_'` in an initializer and
  gets the old names back -- one setting, read wherever a table is named, migrations included
* [Feature] `USA.verify_models` refuses a host whose own class stands where one of these models
  should be, at boot and in one sentence. Zeitwerk gives an app's file precedence over an
  engine's, silently, so a host holding `app/models/city.rb` would otherwise find every
  association here pointing at a class this gem knows nothing about
* [Feature] `USA.seed` passes over a table the host never created, so an app that joins to three
  of the five installs three and seeds three. `bin/rails db:usa:seed` goes on working there
* [Feature] `USA.table` names a table the way the host does, which is what the shipped migrations
  now create and what a host's own migration can read

## 0.3.0 - 2026-09-14

* [Feature] Every model answers by the word a host means rather than by the table under it:
  `zips_path`, `zip[...]`, `zips/_row`, and the i18n key `zip`, while the table stays
  `usa_zips`. Same for a state, a county and a city. A host that lists these records writes
  what it would have written for a model of its own, and a gem that resolves a model from a
  route -- recourse does -- finds it without being told

## 0.2.0 - 2026-09-14

* [Feature] `google_place_id` filled for every state and ZIP, and for the twenty counties that
  were blank: 50 of 51 states, 3,142 of 3,144 counties and 40,818 of 40,977 ZIPs, each the ID of
  a place of the row's own kind, asked of the Geocoding API by component rather than by address
  -- a state by its name and then its code, a county by its name and state, a ZIP by its code.
  What stays blank is what Google has no such place for: the District of Columbia, Broomfield
  County and Wrangell, which it keeps as cities, and 159 ZIPs it folds into a neighbor's. Cities
  wait for a run of their own. `bin/geocode` is what fills a file, eight requests at a time,
  taking only an answer of the right kind and logging the rest

## 0.1.0 - 2026-09-14

* [Feature] `USA::State`, `USA::County` and `USA::ZIP`, on `usa_states`, `usa_counties` and
  `usa_zips`: the three tables three apps were each keeping, each with a CSV and a backfill of
  its own. A state has a code, a FIPS and a name; a county a FIPS, a name and a state; a ZIP a
  code, the city it is addressed as, a time zone named as Rails names one, and one county
* [Feature] `USA::City` on `usa_cities`, and `USA::CityCounty` on `usa_city_counties`: a city
  belongs to one state and lies in one or more counties, so `city.counties` and `county.cities`
  both answer. The place FIPS is unique within a state rather than nationally, which is what the
  index says
* [Feature] `google_place_id` on all four, filled for every county and blank elsewhere until a
  release fills it -- which is a reason `db:usa:seed` exists
* [Feature] `bin/rails g usa:install`, which copies the six migrations into the host under
  timestamps of its own, and writes nothing else: there is nothing here to configure
* [Feature] `USA.seed`, and a `seed` on each model: every write is an upsert keyed on the code
  or the FIPS, so a second run inserts what is missing, leaves the id of every row a host
  already had, and does not touch the `updated_at` of a row that did not change
* [Feature] `bin/rails db:usa:seed`, which is how a database made from `db/schema.rb` gets its
  rows -- a dump carries none -- and how one catches up with a release that added some
* [Feature] `usa_states.counties_count` and `usa_counties.zips_count`, counted from the rows
  after a seed, since an upsert runs no callback, and only where the count moved
* [Feature] The acronyms `USA`, `ZIP` and `FIPS`, registered before the engine loads, so
  `USA::ZIP` is the class, `usa_zips` the table and 'ZIP' the heading
* [Feature] A load hook per model -- `ActiveSupport.on_load(:usa_zip) { ... }` -- and
  `:usa_record`, where a host says how these tables connect

The data is the current Census vintage: the counties include Connecticut's nine planning
regions and Alaska's current census areas, and the places come from the 2025 Gazetteer rather
than the 2010 list one of the three apps was still carrying.
