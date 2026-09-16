class CreateCityCounties < ActiveRecord::Migration[8.1]
  def change
    create_table USA.table(:city_counties), id: false do |t|
      t.references :city, null: false, index: false,
        foreign_key: { to_table: USA.table(:cities) }
      t.references :county, null: false, foreign_key: { to_table: USA.table(:counties) }
      t.index %i[city_id county_id], unique: true
    end
  end
end
