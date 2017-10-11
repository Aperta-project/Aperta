module DataTransformation
  # Swaps fieldset card contents (which are not remove) with display-children
  # with the field-set custom class
  class ReplaceFieldSetCardContentTypes < Base
    counter :field_set_card_content_found

    def transform
      CardContent.where(content_type: 'field-set').each do |cc|
        increment_counter(:field_set_card_content_found)
        log("Migrating card content id: #{cc.id})")
        cc.update!(content_type: 'display-children', custom_class: 'card-content-field-set')
      end
      fieldset_cc = CardContent.where(content_type: 'field-set')
      assert(
        fieldset_cc.empty?,
        "#{fieldset_cc} field-set card contents still present!"
      )
    end
  end
end
