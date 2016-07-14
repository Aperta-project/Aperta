##
# For transforming ruby names into ember names
#
module Emberize
  def self.class_name(klass)
    classname = klass.name.demodulize
    classname.singularize.camelize(:lower)
  end
end
