# A state of the United States, or the District of Columbia.
class State < USA::Record
  include USA::Seeded

  has_many :counties, dependent: :destroy
  has_many :cities, dependent: :destroy

  validates :code, presence: true, length: { is: 2 }, uniqueness: true
  validates :fips, presence: true, length: { is: 2 }, uniqueness: true
  validates :name, presence: true, uniqueness: true

  # Counts the counties of every state the count is wrong for, and touches none of the others.
  # @return [void]
  def self.recount_counties
    where("counties_count <> (#{counted_counties})").
      update_all [ "counties_count = (#{counted_counties}), updated_at = ?", Time.current ]
  end

  # @return [String] the default representation (used in views).
  def to_s = name

  class << self
  private

    # How many counties a state holds, asked of the rows: an upsert runs no callback to keep it.
    def counted_counties
      theirs = County.table_name

      "SELECT COUNT(*) FROM #{theirs} WHERE #{theirs}.state_id = #{table_name}.id"
    end

    def natural_key = :code

    def seeds
      csv('states').lazy.map do |row|
        { code: row['code'], fips: row['fips'], name: row['name'],
          google_place_id: row['google_place_id'], }
      end
    end
  end
end

ActiveSupport.run_load_hooks :usa_state, State
