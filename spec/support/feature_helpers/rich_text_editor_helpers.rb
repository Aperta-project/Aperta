module RichTextEditorHelpers
  def id_for_editor(name)
    selector = ".rich-text-editor[data-editor='#{name}']"
    stuff = "$(\"#{selector}\").attr('id')"
    page.evaluate_script(stuff)
  end

  def fill_in_rich_text(editor:, with: value)
    id = id_for_editor(editor)
    editor = "tinymce.editors.#{id}"
    binding.pry
    page.execute_script("#{editor}.setContent('#{value}')")
    page.execute_script("#{editor}.triggerSave()")
  end
end
