require 'cargobull/extensions/string'
require 'cargobull/env'
require 'cargobull/service'
require 'cargobull/dispatch'
require 'cargobull/rackup'

if File.exist?('./setup.rb')
  require 'cargobull/initialize'
  require './setup'
  Cargobull::Initialize.init_all
end
