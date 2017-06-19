# Provides a base template context
class TemplateContext < Liquid::Drop
  attr_accessor :object

  def self.whitelist(*args)
    args.each do |method|
      delegate method, to: :@object
    end
  end

  def initialize(object)
    @object = object
  end
end
