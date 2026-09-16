require 'active_support/inflector'
require 'csv'

# Before the engine, so Zeitwerk reads zip.rb as ZIP and a heading says ZIP, not Zip.
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'USA'
  inflect.acronym 'ZIP'
  inflect.acronym 'FIPS'
end

require 'usa/version'
require 'usa/engine'

# The geography of the United States: the states, counties, cities and ZIPs an address names.
module USA
  # What every table this gem ships is named with. Empty, so a host joins to `states` and
  # `zips`; set it to `usa_` from an initializer to keep this gem's tables to themselves.
  mattr_accessor :table_name_prefix, default: ''

  # Raised for every failure this gem reports, so a host can rescue one type.
  class Error < StandardError; end

  # The name one of this gem's tables goes by in the host, which is what its migrations create.
  # @return [Symbol] prefixed table name.
  def self.table(name) = :"#{table_name_prefix}#{name}"

  # Writes every row this release holds, keeping the id of every row the database already has.
  # A table the host never created is passed over, so an app that joins to three of the five
  # installs three and seeds them.
  # @return [void]
  def self.seed
    [ State, County, City, CityCounty, ZIP ].select(&:table_exists?).each(&:seed)
    State.recount_counties
    County.recount_zips
  end

  # Refuses a host's own class standing where one of this gem's models should be. Zeitwerk
  # gives an app's file precedence over an engine's, silently, so without this a host holding
  # `app/models/city.rb` would find every association of this gem's pointing at a class of its
  # own.
  # @param [Array<Class>] models the classes the names this gem takes answer to.
  # @return [void]
  def self.verify_models(*models)
    theirs = models.reject { |model| model < Record }
    return if theirs.empty?

    raise Error, "The usa gem defines #{theirs.join ' and '}, and a class of your own has " \
      'taken the name. Rename yours: Rails gives an app’s file precedence over an engine’s, ' \
      'silently, so the models this gem ships would point at a class it knows nothing about.'
  end
end
