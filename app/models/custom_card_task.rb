# This class represents a customized Task built with CardContent
class CustomCardTask < Task
  # This sets all custom cards to be snapshottable submission tasks. Another
  # mechanism for handling these class-level attributes on the custom card's
  # latest version instance will be needed as soon as we convert a legacy card
  # that is not both a submission task and snapshottable.
  include MetadataTask
  DEFAULT_TITLE = 'Custom Card'.freeze

  # unlike other answerables, a CustomCardTask class does not have
  # a concept of a latest card_version.  This is only determinable
  # from an instance of a CustomCardTask
  def default_card
    # noop
  end
end
