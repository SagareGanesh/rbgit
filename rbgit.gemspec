require "#{File.dirname(__FILE__)}/lib/rbgit/version"

Gem::Specification.new do |s|
  s.name        = 'rbgit'
  s.version     = Rbgit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = '2016-03-08'
  s.summary     = "Demo application for practicing Git and Ruby"
  s.description = "A simple Ruby Git gem"
  s.authors     = ["Ganesh Sagare"]
  s.email       = 'ganesh@joshsoftware.com'
  s.homepage    = "https://github.com/SagareGanesh/rbgit"
  s.files       = Dir.glob("{bin,lib}/**/*")
  s.require_paths = ["lib".freeze]
  s.executables = ["rbgit"]
  s.required_ruby_version = ">= 2.1.7"
  s.rubyforge_project = "rbgit"

  s.add_development_dependency 'thor', '~> 0.19.1'
  s.add_development_dependency 'colorize', '~> 0.7.7'
end
