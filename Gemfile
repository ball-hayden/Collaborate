source 'https://rubygems.org'

# Declare your gem's dependencies in collaborate.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# As ActionCable is still unstable, let's use master:
gem 'actioncable', github: 'rails/actioncable'

group :development do
  gem 'byebug'

  # For dummy app
  gem 'mysql2', '< 0.4'

  gem 'jquery-rails'

  gem 'puma'
end
