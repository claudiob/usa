require 'action_dispatch'
require 'rails/engine'

module USA
  # Teaches Rails where this gem's models live, and refuses a host that has taken their names.
  class Engine < ::Rails::Engine
    # Asked when Active Record loads rather than while the app boots: reaching for these
    # models pulls Active Record in behind them, and pulling it in before initialization is
    # over slows every boot and can reorder a host's own -- which is what Rails warns about.
    ActiveSupport.on_load(:active_record) do
      USA.verify_models ::State, ::County, ::City, ::CityCounty, ::ZIP
    end
  end
end
