# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :runtime, :cli do
  gem 'docopt', '~> 0.6' # for argument parsing
  gem 'paint', '~> 2.3' # for colorized ouput
  # hivex not available as a gem but only shipped as a wrapper of the system library
end

group :development, :install do
  gem 'bundler', '~> 2.1'
end

group :development, :lint do
  gem 'rubocop', '~> 1.65'
end
