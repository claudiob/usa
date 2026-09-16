# A ZIP code, and the city, time zone and county the Postal Service delivers it in.
class ZIP < USA::Record
  include USA::Seeded

  belongs_to :county, counter_cache: true

  validates :code, presence: true, length: { is: 5 }, uniqueness: true
  validates :city, presence: true
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.us_zones.map(&:name) }

  # @return [String] the default representation (used in views).
  def to_s = code

  class << self
  private

    def natural_key = :code

    def seeds
      counties = County.pluck(:fips, :id).to_h
      csv('zips').lazy.map do |row|
        { code: row['code'], city: row['city'], time_zone: row['time_zone'],
          county_id: counties.fetch(row['county']), google_place_id: row['google_place_id'], }
      end
    end
  end
end

ActiveSupport.run_load_hooks :usa_zip, ZIP
