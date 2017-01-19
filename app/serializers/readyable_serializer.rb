module ReadyableSerializer
  extend ActiveSupport::Concern

  included do
    attributes :ready, :ready_issues
  end

  def ready
    object.ready?
  end

  def ready_issues
    object.ready_issues.try(:messages).as_json
  end
end
