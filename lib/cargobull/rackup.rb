
module Cargobull
  class Rackup
    def file(path)
      path.sub!(/^\/files/i, '')
      path = "./files#{path}"
      [200, {}, File.exist?(path) ? File.open(path, File::RDONLY) : ""]
    end

    def dispatch(env)
      req = Rack::Request.new(env)
      action = env["REQUEST_PATH"].sub(/^\//, '').gsub(/\/[^\/]+/, '')
      params = req.POST.merge(req.GET)
      data = Cargobull::Dispatch.call(env["REQUEST_METHOD"], action, params)
      return [200, {}, data]
    rescue RuntimeError
      return [404, {}, "Not found"]
    end

    def call(env)
      return env["REQUEST_PATH"] =~ /^\/files\/|^\/favicon/i ?
        self.file(env["REQUEST_PATH"]) : self.dispatch(env)
    end
  end
end
