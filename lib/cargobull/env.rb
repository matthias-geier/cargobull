
module Cargobull
  def self.env
    return Env
  end

  class Env
    def self.dispatch_url
      return @dispatch_url || '/'
    end

    def self.dispatch_url=(url)
      raise ArgumentError.new("Reserved url #{url}") if url =~ /^\/files(\/|$)/i
      @dispatch_url = url.empty? || url[0] != '/' ? "/#{url}" : url
    end

    def self.serve_url
      return ['', '/'].include?(self.dispatch_url) ? '/files' : '/'
    end
  end
end
