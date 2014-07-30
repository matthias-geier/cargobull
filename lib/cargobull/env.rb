
module Cargobull
  def self.env
    return Env
  end

  class Env
    @dispatch_url = "/"
    @serve_url = "/files"

    def self.dispatch_url
      return @dispatch_url
    end

    def self.dispatch_url=(url)
      sanitized_url = (url || "").split('/').reject(&:empty?).first
      @dispatch_url = sanitized_url ? "/#{sanitized_url}" : "/"
      @serve_url = sanitized_url ? "/" : "/files"
    end

    def self.serve_url
      return @serve_url
    end
  end
end
