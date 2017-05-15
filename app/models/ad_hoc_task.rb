# AdHocTask is a user-customizeable task type
class AdHocTask < Task
  DEFAULT_TITLE = 'Ad-hoc for Staff Only'.freeze

  # Avoid resetting adhoc task title and role
  def self.restore_defaults
  end

  # type can be "attachments", "text", "email", "h1"
  # for adhoc tasks, the body is composed of an array of 'blocks',
  # each of which are composed of an array of items.
  # There can be more than one item in a block, but every item will have the same "type",
  # hence we can see what 'type' the block is by just looking at the first item.
  # [
  #   [{ "type" => "text", "value" => "foo" }],
  #   [{ "type" => "checkbox", "value" => "foo" }
  #    { "type" => "checkbox", "value" => "bar" }
  #   ],
  #   [{ "type" => "attachments", "value" => "Please select a file." }]
  # ]
  def blocks(type)
    body.select { |b| b[0]["type"] == type }
  end
end
