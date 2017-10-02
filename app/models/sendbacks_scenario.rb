# Provides a template context for the Sendback Reasons Letter Template
class SendbacksScenario < TemplateScenario
  def self.complex_merge_fields
    [{ name: :task, context: SendbacksContext }]
  end

  def task
    SendbacksContext.new(@object)
  end

  private

  # def task
  #   @object
  # end
end
