require 'test_helper'
require 'rails/generators/test_case'
require 'generators/usa/install/install_generator'

class USA::Generators::InstallGeneratorTest < Rails::Generators::TestCase
  tests USA::Generators::InstallGenerator
  destination Rails.root.join 'tmp/generated'
  setup :prepare_destination

  test 'an install hands the host every migration, under timestamps of its own' do
    run_generator

    assert_migration 'db/migrate/create_states.rb', /create_table USA\.table\(:states\)/
    assert_migration 'db/migrate/create_counties.rb', /to_table: USA\.table\(:states\)/
    assert_migration 'db/migrate/create_zips.rb', /to_table: USA\.table\(:counties\)/
    assert_migration 'db/migrate/create_cities.rb', /%i\[state_id fips\], unique: true/
    assert_migration 'db/migrate/create_city_counties.rb', /id: false/
    assert_migration 'db/migrate/seed_usa.rb', /up_only \{ USA\.seed \}/
  end

  test 'the generator answers to the name somebody types, which Thor would not have given it' do
    assert_equal 'usa:install', USA::Generators::InstallGenerator.namespace
  end
end
