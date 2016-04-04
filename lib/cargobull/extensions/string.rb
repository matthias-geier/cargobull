# = String class extension
#
# A string that is supposed to becode a Module, Class or similar can be
# transformed by using #constantize
#
#   "Array".constantize
#   => Array
#
# When writing file names in ruby, they are usually an underscore (snakecase)
# representation of the class name. It can be transformed with #camelize and
# in place with #camelize!
#
#   "file_reader".camelize
#   => "FileReader"
#
#   s = "file_reader"
#   s.camelize!
#   s
#   => "FileReader"
#
# The backwards transformation from a class name to snakecase is done with
# #underscore and in place with #underscore!
#
#   "FileReader".underscore
#   => "file_reader"
#
#   s = "FileReader".underscore
#   s.underscore!
#   s
#   => "file_reader"
#
#
#
class String
  def constantize
    split('::').reduce(Module){ |m, c| m.const_get(c) }
  end

  def path_to_modules
    split(/\//).map(&:capitalize).join('::')
  end

  def modules_to_path
    sub(/:+/, '/')
  end

  def camelize
    split(/_/).map(&:capitalize).join.path_to_modules
  end

  def camelize!
    replace(camelize)
  end

  def underscore
    modules_to_path.split(/([A-Z]?[^A-Z]*)/).reject(&:empty?).
      map(&:downcase).join('_').gsub(/\/_/, '/')
  end

  def underscore!
    replace(underscore)
  end
end
