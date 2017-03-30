# This class represents a customized Task built with CardContent
class CustomCardTask < Task
  DEFAULT_TITLE = 'Custom Card'.freeze

  validates :card_version, presence: true
end
