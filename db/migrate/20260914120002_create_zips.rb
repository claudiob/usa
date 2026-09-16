class CreateZips < ActiveRecord::Migration[8.1]
  def change
    create_table USA.table(:zips) do |t|
      t.string :code, limit: 5, null: false, index: { unique: true }
      t.string :city, null: false, index: true
      t.string :time_zone, null: false
      t.references :county, null: false, foreign_key: { to_table: USA.table(:counties) }
      t.string :google_place_id
      t.timestamps
    end
  end
end
