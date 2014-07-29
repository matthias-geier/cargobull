
module Cargobull
  class Rackup
    def file(path)
      path.sub!(/^#{Cargobull.env.serve_url}\/?/i, '')
      path = "./files/#{path}"
      [200, {}, File.exist?(path) ? File.open(path, File::RDONLY) : ""]
    end

    def dispatch(env)
      req = Rack::Request.new(env)
      action = env["REQUEST_PATH"].sub(/^#{Cargobull.env.dispatch_url}\/?/, '').
        gsub(/\/[^\/]+/, '')
      params = req.POST.merge(req.GET)
      data = Cargobull::Dispatch.call(env["REQUEST_METHOD"], action, params)
      return [200, {}, data]
    rescue RuntimeError
      return [404, {}, "Not found"]
    end

    def call(env)
      path = env["REQUEST_PATH"]
      if path =~ /^#{Cargobull.env.serve_url}\/?|^\/favicon/i &&
        path !~ /^#{Cargobull.env.dispatch_url}\/?/i

        return self.file(path)
      else
        return self.dispatch(env)
      end
    end
  end
end
