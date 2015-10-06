module Collaborate
  class Engine < ::Rails::Engine
    isolate_namespace Collaborate

    initializer 'collaborate.vendor_assets' do |app|
      app.config.assets.paths << root.join('vendor', 'bower_components')
    end

    config.generators do |g|
      g.test_framework :rspec
      g.factory_girl suffix: 'factory'
      g.helper false
      g.stylesheets false
      g.javascripts false
    end
  end
end
