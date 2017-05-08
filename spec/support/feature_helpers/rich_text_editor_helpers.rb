module RichTextEditorHelpers
  def id_for_editor(name)
    selector = ".rich-text-editor[data-editor='#{name}']"
    find_editor_id = "$(\"#{selector}\").find('iframe').contents().find('body').data('id')"
    page.evaluate_script(find_editor_id)
  end

  def fill_in_rich_text(editor:, text:)
    id = id_for_editor(editor)
    throw "missing editor id: #{editor}" if id.blank?

    instance = "tinymce.editors.#{id}"
    page.execute_script("#{instance}.setContent(#{text.to_json})")
    page.execute_script("#{instance}.target.triggerSave()")
  end
end
