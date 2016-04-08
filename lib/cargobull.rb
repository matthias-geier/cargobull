require 'cargobull/extensions/string'
require 'cargobull/env'
require 'cargobull/service'
require 'cargobull/dispatch'
require 'cargobull/rackup'

module Cargobull
  def self.runner(cargoenv=env.get)
    ->(env) do
      cargoenv[:rackenv] = env
      cargoenv[:request_path] = env["REQUEST_PATH"]
      cargoenv[:request_method] = env["REQUEST_METHOD"]
      cargoenv.freeze
      Rackup.call(cargoenv)
    end
  end

  #def self.streamer(cargoenv=env.get)
  #  cargoenv[:session] = {}
  #  cargoenv.freeze
  #  Stream.call(cargoenv)
  #end
end

if File.exist?('./setup.rb')
  require 'cargobull/initialize'
  require './setup'
  Cargobull::Initialize.init_all
end
