module Attributable
	extend ActiveSupport::Concern

	CONTENT_ATTRIBUTES = {
		boolean: %w[allow_annotations allow_file_captions allow_multiple_uploads required_field],
		string:  %w[condition default_answer_value editor_style error_message
		            instruction_text label text value_type visible_with_parent_answer],
		json:    %w[possible_values]
	}.freeze

	included do
		CONTENT_ATTRIBUTES.each do |_type, names|
			names.each do |name|
				define_method(name) do
					content_attributes.named(name).try(&:value)
				end

				define_method("#{name}=") do |contents|
					content_attributes.named(name).try { |attr| attr.value = contents }
				end
			end
		end
	end
end
