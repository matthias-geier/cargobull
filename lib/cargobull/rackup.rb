
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
      match_stack = [
        [Cargobull.env.serve_url,
          path =~ /^#{Cargobull.env.serve_url}\/?|^\/favicon/i,
          lambda{ self.file(path) }],
        [Cargobull.env.dispatch_url,
          path =~ /^#{Cargobull.env.dispatch_url}\/?/i,
          lambda{ self.dispatch(env) }]
      ].select{ |_, hit, _| hit }

      # both hit, one is a slash, so pick the other one and call it
      match_stack.sort!{ |(p1, _, _), (p2, _, _)| p2.length <=> p1.length }
      return match_stack.first.last.call
    end
  end
end
