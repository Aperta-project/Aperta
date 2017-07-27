# This class represents a customized Task built with CardContent
class CustomCardTask < Task
  DEFAULT_TITLE = 'Custom Card'.freeze
  has_many :apex_deliveries, foreign_key: 'task_id', class_name: "TahiStandardTasks::ApexDelivery", dependent: :destroy
  # unlike other answerables, a CustomCardTask class does not have
  # a concept of a latest card_version.  This is only determinable
  # from an instance of a CustomCardTask
  def default_card
    # noop
  end
end
