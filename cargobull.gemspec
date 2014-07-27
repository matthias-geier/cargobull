Gem::Specification.new do |s|
  s.name = "cargobull"
  s.version = '0.0.1'
  s.summary = "Multipurpose dispatcher for RESTful services"
  s.author = "Matthias Geier"
  s.homepage = "https://github.com/matthias-geier/cargobull"
  s.licenses = ['BSD-2']
  s.require_path = 'lib'
  s.files = Dir['lib/*.rb'] + Dir['lib/cargobull/*.rb'] +
    Dir['lib/cargobull/extensions/*.rb'] + [ "LICENSE.md" ]
  s.executables = []
  s.required_ruby_version = '>= 2.1.0'
  #s.add_runtime_dependency('redis', '~> 3.1')
end
