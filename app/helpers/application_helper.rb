module ApplicationHelper
  def active_link_to link_text, path
    link_to_unless_current link_text, path do
      link_to link_text, path, class: 'active'
    end
  end

  def card task
    classes = ['card'].tap { |a| a << 'completed' if task.completed? }

    capture_haml do
      haml_concat(link_to(
        paper_task_path(task.paper, task),
        class: classes.join(' '),
        data: {
          'task-path' => paper_task_path(task.paper, task),
          'task-id' => task.id,
          'card-name' => task.class.name.underscore.dasherize.gsub(/-task/, '')
        }
      ) do
        haml_tag :span, class: 'glyphicon glyphicon-ok'
        haml_concat task.title
      end)
    end
  end
end
