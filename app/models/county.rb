# A county, parish, borough or census area: the division every ZIP is counted under.
class County < USA::Record
  include USA::Seeded

  belongs_to :state, counter_cache: true

  has_many :city_counties, dependent: :delete_all
  has_many :cities, through: :city_counties
  has_many :zips, dependent: :destroy

  validates :fips, presence: true, length: { is: 5 }, uniqueness: true
  validates :name, presence: true

  # Counts the ZIPs of every county the count is wrong for, and touches none of the others.
  # @return [void]
  def self.recount_zips
    where("zips_count <> (#{counted_zips})").
      update_all [ "zips_count = (#{counted_zips}), updated_at = ?", Time.current ]
  end

  # @return [String] the default representation (used in views).
  def to_s = "#{name} (#{state.code})"

  class << self
  private

    # How many ZIPs a county holds, asked of the rows: an upsert runs no callback to keep it.
    def counted_zips
      theirs = ZIP.table_name

      "SELECT COUNT(*) FROM #{theirs} WHERE #{theirs}.county_id = #{table_name}.id"
    end

    def natural_key = :fips

    def seeds
      states = State.pluck(:code, :id).to_h
      csv('counties').lazy.map do |row|
        { fips: row['fips'], name: row['name'], state_id: states.fetch(row['state']),
          google_place_id: row['google_place_id'], }
      end
    end
  end
end

ActiveSupport.run_load_hooks :usa_county, County
