require 'test_helper'

# What seeding leaves behind, asked of the wiring rather than of the rows: which row the CSVs
# happen to hold is data, and data exercises no code of ours.
class USATest < ActiveSupport::TestCase
  test 'seeding writes every row once, joined up and counted, and a second seed changes none' do
    ours = State.create! code: 'NY', fips: '36', name: 'New York'
    USA.seed
    counted = counts

    assert_equal ZIP.count, ZIP.joins(county: :state).count
    assert_equal City.count, City.joins(:counties).distinct.count
    assert_equal County.count, State.sum(:counties_count)
    assert_equal ZIP.count, County.sum(:zips_count)
    assert_equal ours.id, State.find_by(code: 'NY').id

    assert_no_changes -> { County.maximum :updated_at } do
      USA.seed
    end
    assert_equal counted, counts
  end

  test 'the acronyms this gem registers name its classes and its headings' do
    assert_equal 'ZIP', ZIP.model_name.human
    assert_equal 'FIPS', County.human_attribute_name(:fips)
    assert_equal 'sqlite3', USA::Record.connection_db_config.adapter
  end

  test 'the tables are bare, so a host joins to the names it already writes' do
    assert_equal %w[states counties cities city_counties zips],
      [ State, County, City, CityCounty, ZIP ].map(&:table_name)
  end

  test 'a host that wants these tables to itself sets one prefix, and every name takes it' do
    USA.table_name_prefix = 'usa_'

    assert_equal :usa_states, USA.table(:states)
    assert_equal 'usa_zips', ZIP.reset_table_name
  ensure
    USA.table_name_prefix = ''
    ZIP.reset_table_name
  end

  test 'a host that has taken one of these names is told rather than quietly shadowing it' do
    assert_nil USA.verify_models(State, County, City, CityCounty, ZIP)

    error = assert_raises(USA::Error) { USA.verify_models State, String }

    assert_match 'The usa gem defines String', error.message
  end

private

  def counts
    [ State, County, City, CityCounty, ZIP ].map(&:count)
  end
end
