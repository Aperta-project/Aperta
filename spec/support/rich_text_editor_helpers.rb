module RichTextEditorHelpers
  def get_rich_text(editor:)
    instance = editor_instance(editor)
    page.evaluate_script("#{instance}.getContent()")
  end

  def set_rich_text(editor:, text:)
    instance = editor_instance(editor)
    page.execute_script("#{instance}.setContent(#{text.to_json})")
    page.execute_script("#{instance}.target.triggerSave()")
  end

  def wait_for_editors(timeout: Capybara.default_max_wait_time, count: 1)
    Timeout.timeout(timeout) do
      sleep 0.5
      loop until page.evaluate_script("$('iframe').length").to_i >= count
    end
  end

  def editor_instance(name)
    "tinymce.editors.#{editor_id(name)}"
  end

  def within_editor_iframe(name)
    page.within_frame("#{editor_id(name)}_ifr") do
      yield
    end
  end

  def editor_id(name)
    selector = ".rich-text-editor[data-editor='#{name}']"
    find_editor_id = "$(\"#{selector}\").find('iframe').contents().find('body').data('id')"
    id = page.evaluate_script(find_editor_id)
    throw "missing editor id: #{name}" if id.blank?
    id
  end
end
