# Where a city lies: one row per county it reaches into, since a city may span several.
class CityCounty < USA::Record
  include USA::Seeded

  belongs_to :city
  belongs_to :county

  class << self
  private

    def natural_key = %i[city_id county_id]

    def seeds
      cities = City.joins(:state).
        pluck("#{State.table_name}.code", :fips, "#{City.table_name}.id").
        to_h { |code, fips, id| [ [ code, fips ], id ] }
      counties = County.pluck(:fips, :id).to_h
      csv('cities').lazy.flat_map do |row|
        city_id = cities.fetch [ row['state'], row['fips'] ]
        row['counties'].split.map { |fips| { city_id:, county_id: counties.fetch(fips) } }
      end
    end
  end
end

ActiveSupport.run_load_hooks :usa_city_county, CityCounty
