Gem::Specification.new do |s|
  s.name        = 'nice_assets'
  s.version     = '0.0.0'
  s.date        = '2017-10-01'
  s.summary     = "Easily manage dependencies between assets that need to be processed in a specified order"
  s.description = "Define a workflow of dependencies between assets and, easily determine the current set of assets to process, and define hooks to automatically process them in the needed order."
  s.authors     = ["Andrew Schwartz"]
  s.email       = 'ozydingo@gmail.com'
  s.files       = Dir["lib/**/*"]
  s.homepage    = 'https://github.com/ozydingo/nice_assets'
  s.license     = 'MIT'
end