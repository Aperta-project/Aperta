module AttributeNames
  COMMON_ATTRIBUTES = %w[
    child-tag content-type custom-child-class custom-class default-answer-value
    ident value-type visible-with-parent-answer wrapper-tag
  ].freeze

  XML_ATTRIBUTES  = Hash[COMMON_ATTRIBUTES.map {|name| [name.gsub('-', '_'), name]}].freeze
  RUBY_ATTRIBUTES = Hash[COMMON_ATTRIBUTES.map {|name| [name, name.gsub('-', '_')]}].freeze

  FREQUENT_ATTRIBUTES = %w[allow-annotations required-field].freeze
  CUSTOM_ATTRIBUTES = [
    [%w[file-uploader],   %w[allow-file-captions allow-multiple-uploads] + FREQUENT_ATTRIBUTES],
    [%w[if],              %w[condition]],
    [%w[paragraph-input], %w[editor-style] + FREQUENT_ATTRIBUTES],
    [%w[date-picker],     %w[required-field]],
    [%w[check-box drop-down radio short-input tech-check], FREQUENT_ATTRIBUTES],
  ].each_with_object(Hash.new([])) {|(types, attributes), hash| types.each {|type| hash[type] += attributes}}.freeze
end
