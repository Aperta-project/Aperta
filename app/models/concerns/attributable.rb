module Attributable
	extend ActiveSupport::Concern

	CONTENT_ATTRIBUTES = {
		boolean: %w[allow_annotations allow_file_captions allow_multiple_uploads required_field],
		string:  %w[condition default_answer_value editor_style error_message
		            instruction_text label text value_type visible_with_parent_answer],
		json:    %w[possible_values]
	}.freeze

	ATTRIBUTE_CONTENTS = {}

	included do
		CONTENT_ATTRIBUTES.each do |type, names|
			names.each do |name|
				ATTRIBUTE_CONTENTS[name] = type

				define_method(name) do
					result = content_attributes.named(name).try(&:value)
					puts "Calling synthetic method #{name}, returning #{result.class} #{result}"
					result
				end

				define_method("#{name}=") do |contents|
					attr = content_attributes.named(name)
					attr ||= content_attributes.new(name: name, value_type: ATTRIBUTE_CONTENTS[name])
					attr.value = contents
				end
			end
		end
	end
end
