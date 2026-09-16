# A city, town or census designated place: what a street address is addressed to.
class City < USA::Record
  include USA::Seeded

  belongs_to :state

  has_many :city_counties, dependent: :delete_all
  has_many :counties, through: :city_counties

  validates :fips, presence: true, length: { is: 5 },
    uniqueness: { scope: :state_id }
  validates :name, presence: true

  # @return [String] the default representation (used in views).
  def to_s = "#{name} (#{state.code})"

  class << self
  private

    def natural_key = %i[state_id fips]

    def seeds
      states = State.pluck(:code, :id).to_h
      csv('cities').lazy.map do |row|
        { fips: row['fips'], name: row['name'], state_id: states.fetch(row['state']),
          google_place_id: row['google_place_id'], }
      end
    end
  end
end

ActiveSupport.run_load_hooks :usa_city, City
