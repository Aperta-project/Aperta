##
# For transforming ruby names into ember names
#
module Emberize
  def self.class_name(klass)
    classname = klass.base_class.name.demodulize
    classname.singularize.underscore.dasherize.downcase
  end
end
