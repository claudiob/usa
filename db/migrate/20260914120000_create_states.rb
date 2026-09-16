class CreateStates < ActiveRecord::Migration[8.1]
  def change
    create_table USA.table(:states) do |t|
      t.string :code, limit: 2, null: false, index: { unique: true }
      t.string :fips, limit: 2, null: false, index: { unique: true }
      t.string :name, null: false, index: { unique: true }
      t.integer :counties_count, default: 0, null: false
      t.string :google_place_id
      t.timestamps
    end
  end
end
