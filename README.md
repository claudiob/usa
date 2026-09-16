# USA

Every state, county, city and ZIP code of the United States, as five tables a Rails app joins
to. One copy, held here, rather than a CSV and a backfill in each app that needs an address to
mean something.

## How to install

To install on your system, run

    gem install usa

To use inside a bundled Ruby project, add this line to the `Gemfile`:

    gem 'usa', '~> 0.4.0'

Below 1.0 the pin stops at the next minor rather than the next major, because that is where a
breaking change may still land. It becomes `~> 1.0` once the API is settled on purpose.

## Getting the tables

```sh
bin/rails g usa:install   # six migrations, copied into your app and yours to keep
bin/rails db:migrate      # the five tables, and every row in them
```

The last one takes about a minute: it writes 51 states, 3,144 counties, some 32,000 cities and
some 41,000 ZIPs.

Install only the tables you join to. Delete the migrations for the rest before you run them, and
`USA.seed` passes over what is not there — an app that never asks what city an address is in
keeps three tables rather than five.

**A database made from `db/schema.rb` has the tables and none of the rows.** A dump carries no
data, so `db:schema:load`, `db:test:prepare` and a fresh clone all leave the tables empty. Run
`bin/rails db:usa:seed`, or call `USA.seed` from your own `db/seeds.rb`. The same command is how
a database catches up with a release that added rows: every write is an upsert keyed on the code
or the FIPS, so it inserts what is missing, updates what this gem owns, and leaves the id of
every row you already had exactly where it was.

## What you get

```ruby
zip = ZIP.find_by code: '90210'  # => #<ZIP>
zip.city                         # => 'Beverly Hills'
zip.time_zone                    # => 'Pacific Time (US & Canada)'
zip.county                       # => #<County>
zip.county.fips                  # => '06037'
zip.county.state.code            # => 'CA'

county = zip.county
county.zips_count                # => 508
county.cities                    # => [#<City>, ...]

state = county.state
state.counties_count             # => 58
state.counties                   # => [#<County>, ...]
state.cities                     # => [#<City>, ...]
```

A state has a `code`, a `fips` and a `name`. A county has a `fips`, a `name` and a state. A city
has a `fips` -- a Census place code, unique within its state rather than nationally -- a `name`,
a state, and the one or more counties it lies in, since a city may cross a county line. A ZIP has
a `code`, the `city` it is addressed as, a `time_zone` named as Rails names one, and one county.

That county and that city are the main one rather than the only one. A ZIP is a delivery route
rather than an area, and many of them cross a county line: this gem names the county the route
is chiefly in and the city it is chiefly addressed to, and holds nothing about the others. A
city is the exception, keeping every county it lies in, which is why `city.counties` answers
more than one.

Every one of the four also has a `google_place_id`, the ID Google gives the place, which is what
draws a table of them as a map. It is filled for every state, county and ZIP that Google keeps
as an area of its kind, and blank for the few it keeps only as a city -- the District of
Columbia, Broomfield County, Wrangell -- for the ZIPs it folds into a neighbor's, and for every
city until a release fills them.

Two counter caches are kept by the seed rather than by a callback: `states.counties_count` and
`counties.zips_count`.

## The names are yours to write, not to choose

`State`, `County`, `City`, `CityCounty` and `ZIP` are this gem's classes, on `states`,
`counties`, `cities`, `city_counties` and `zips`. They are the words your routes, forms,
partials and locale keys already use, so `belongs_to :zip` finds the class, `zips_path` draws
the page and `zip[...]` names the field -- nothing has to be told which gem the model came from.

Which means this gem takes five names in your app, and a class of your own called `Zip`, `City`
or `State` cannot stand beside them. Rails gives your `app/models/city.rb` precedence over an
engine's, silently, so the gem checks at boot and refuses to start rather than let every
association here point at a class it knows nothing about:

    The usa gem defines City, and a class of your own has taken the name. Rename yours: …

The gem also registers `USA`, `ZIP` and `FIPS` as acronyms, so `ZIP` is the spelling everywhere
-- a heading, a route helper, a migration's class name.

If you want these tables to themselves, name them:

```ruby
# config/initializers/usa.rb
USA.table_name_prefix = 'usa_'
```

One setting, read wherever a table is named: the models, the counter queries, and the migrations
the generator hands you. Set it before anything queries, which an initializer is. The class
names are not configurable -- Active Record resolves `belongs_to :zip` by asking for a class
called `ZIP`, and nothing but a class of that name will do.

## Making them yours

Each model runs a load hook, so an app adds to it without reopening a file it does not own:

```ruby
# config/initializers/usa.rb
ActiveSupport.on_load(:usa_zip) do
  has_many :bookings, dependent: :destroy

  scope :served, -> { where.not markets_count: 0 }
end
```

`:usa_state`, `:usa_county`, `:usa_city`, `:usa_city_county` and `:usa_zip` are the five, and
`:usa_record` is where an app says how all of them connect -- a reading role, say, which these
models otherwise know nothing about:

```ruby
ActiveSupport.on_load(:usa_record) { connects_to database: { writing: :primary, reading: :reader } }
```

Columns of your own go on these tables in a migration of your own. They survive every seed: this
gem writes only the columns it ships.

## Adopting it in an app that already has these tables

Your tables are already called `states`, `counties` and `zips`, so there is nothing to rename:
add the columns this gem's own carry that yours lack -- `google_place_id`, the counter caches,
a ZIP's city and time zone -- and seed. Every id stays where it is, because the seed upserts on
the code or the FIPS rather than on the id, and every foreign key of yours goes on pointing at
the row it pointed at.

Delete the models you had for them, and say through the load hooks what they said. Where your
rows were loaded with explicit ids, run `setval` on the sequence before the first seed, or the
first insert collides.

Two things to know. A class of yours called `Zip` stops being found the day you install this,
which the boot check will tell you. And `State` and `County` cascade to `cities` with
`dependent: :destroy`, so an app that skipped those tables must not destroy one.

## Development

`bin/setup` gets a clone working, `bin/console` opens a prompt with the library loaded, and
`bundle exec rake` runs the suite, the linter and the two size limits. The dummy app under
`test/dummy` is SQLite on purpose: it is a fixture rather than an app, and running the seed's
upserts and the counter statements on a second adapter, with no server to start, is worth more
than resembling the apps that install this.

`bin/geocode` is the maintainer's, not the gem's: it fills the blank place ids in one CSV from
the Google Geocoding API and is not packaged.

## Reference

The API reference is built from what RubyGems holds, at
[rubydoc.info/gems/usa](https://rubydoc.info/gems/usa). The source is at
[github.com/claudiob/usa](https://github.com/claudiob/usa).

## License

MIT, see [LICENSE.txt](LICENSE.txt).
