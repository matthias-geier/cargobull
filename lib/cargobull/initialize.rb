
module Cargobull
  module Initialize
    @file_map = {}

    def self.sanitize_file_name(file_name)
      return file_name =~ /^\.\// ? file_name : "./#{file_name}"
    end

    def self.dir(*args)
      sanitized_args = args.map{ |d| sanitize_file_name(d) }.
        map{ |d| d.sub(/\/$/, '') }.
        select{ |d| File.directory?(dir) }

      sanitized_args.each do |dir|
        ruby_files = Dir.open(dir).select{ |f| f =~ /\.rb$/ }
        @file_map = ruby_files.reduce(@file_map) do |acc, f|
          camel_file = f.sub(/\.rb$/, '').camelize
          Object.autoload(camel_file, "#{d}/#{f}")
          acc[camel_file] = "#{d}/#{f}"
          next acc
        end
      end
    end

    def self.file(klass_str, file_name)
      file_name = sanitize_file_name(file_name)
      return unless File.file?(file_name)
      Object.autoload(klass_str, file_name)
      @file_map[klass_str] = file_name
    end

    def self.init_all
      @file_map.each{ |_, file| require file }
    end
  end
end
