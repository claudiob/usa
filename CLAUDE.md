# CLAUDE.md

USA is a Ruby gem: a Rails engine holding the geography of the United States as five tables any
app joins to — `states`, `counties`, `cities`, `city_counties`, `zips` — under the models
`State`, `County`, `City`, `CityCounty` and `ZIP`. It exists because fountain, houston and
autopilot each kept a copy of that data, and the copies drifted apart.

## How USA differs from a standard gem

- It ships data. Four CSVs under `db/seeds/` carry the rows, and `USA.seed` writes them with an
  upsert keyed on the code or the FIPS, so a re-run keeps the id of every row a host already had
- Its models are top level and its tables bare, so a host writes `belongs_to :zip` and Active
  Record finds the class. That takes five names in every host, which `USA.verify_models` refuses
  to let a host's own class shadow, and it is why a namespace is not on offer
- A host that wants these tables to itself sets `USA.table_name_prefix`, which every table name
  is read through — the models, the counter queries and the shipped migrations
- Its migrations are copied into a host by `bin/rails g usa:install` rather than loaded off the
  gem, so the host owns them and may add columns of its own to these tables
- The dummy app under `test/dummy` is SQLite on purpose: it is a fixture, not an app
- It registers the acronyms `USA`, `ZIP` and `FIPS` in the host's inflections

## How to work on this codebase

Follow the coding guidelines available locally at ../guidelines/STYLE.md and online at
https://raw.githubusercontent.com/HouseAccountEng/guidelines/refs/heads/main/STYLE.md

Read them before making a change, including the sections on what a gem always ships, on a gem's
GitHub Page, and on the git rules — one prompt, one commit, and no trailer naming who wrote it.

## Related projects

Can also be found locally (under `../[name]`) or on GitHub (under
`https://github.com/HouseAccountEng/[name]`):

Rails apps that hold or will hold this data: autopilot, fountain, houston
Ruby gems: alt, company, hcn, hcp, guidelines, jbr, omen, recourse, twi, unicon
