class CreateCounties < ActiveRecord::Migration[8.1]
  def change
    create_table USA.table(:counties) do |t|
      t.string :fips, limit: 5, null: false, index: { unique: true }
      t.string :name, null: false, index: true
      t.references :state, null: false, foreign_key: { to_table: USA.table(:states) }
      t.integer :zips_count, default: 0, null: false
      t.string :google_place_id
      t.timestamps
    end
  end
end
