# frozen_string_literal: true

require_relative 'lib/hivexcavator/version'

Gem::Specification.new do |s|
  s.name          = 'hivexcavator'
  s.version       = HivExcavator::VERSION
  s.platform      = Gem::Platform::RUBY
  s.summary       = 'Parse BCD files to extract WIM files path (among other stuff)'
  s.description   = 'Extracting the contents of Microsoft Windows Registry (hive) and display it as a colorful tree ' \
                    'but mainly focused on parsing BCD files to extract WIM files path for PXE attacks.'
  s.authors       = ['Alexandre ZANNI']
  s.email         = 'alexandre.zanni@europe.com'
  s.homepage      = 'https://acceis.github.io/hivexcavator/'
  s.license       = 'MIT'

  s.files         = Dir['bin/*'] + Dir['lib/**/*.rb'] + ['LICENSE.txt']
  s.bindir        = 'bin'
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.metadata = {
    'yard.run' => 'yard',
    'bug_tracker_uri' => 'https://github.com/acceis/hivexcavator/issues',
    'changelog_uri' => 'https://github.com/acceis/hivexcavator/blob/master/docs/CHANGELOG.md',
    'documentation_uri' => 'https://acceis.github.io/hivexcavator/',
    'homepage_uri' => 'https://acceis.github.io/hivexcavator/',
    'source_code_uri' => 'https://github.com/acceis/hivexcavator/',
    'rubygems_mfa_required' => 'true'
  }

  s.required_ruby_version = ['>= 3.0.0', '< 4.0']

  s.add_runtime_dependency('docopt', '~> 0.6') # for argument parsing
  s.add_runtime_dependency('paint', '~> 2.3') # for colorized output
end
