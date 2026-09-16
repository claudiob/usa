require 'action_dispatch'
require 'rails/engine'

module USA
  # Teaches Rails where this gem's models live, and refuses a host that has taken their names.
  class Engine < ::Rails::Engine
    config.to_prepare { USA.verify_models ::State, ::County, ::City, ::CityCounty, ::ZIP }
  end
end
