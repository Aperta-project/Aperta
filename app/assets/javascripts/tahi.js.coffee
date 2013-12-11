window.Tahi ||= {}

Tahi.init = ->
  Tahi.papers.init()
  Tahi.overlays.authors.init()
  Tahi.overlays.figures.init()

  for form in $("form.js-submit-on-change[data-remote='true']")
    @setupSubmitOnChange $(form), $('select, input[type="checkbox"], textarea', form)

  for element in $('[data-overlay-name]')
    Tahi.initOverlay(element)

Tahi.setupSubmitOnChange = (form, elements) ->
  elements.on 'change', (e) ->
    form.trigger 'submit.rails'

Tahi.displayOverlay = (element) ->
  overlay = $('#overlay')

  $element = $(element)
  overlayName = $element.data('overlay-name')
  overlayTitle = $element.data('overlay-title')

  titleContainer = $('header h2', overlay)
  titleContainer.text overlayTitle

  taskId = $element.data('task-id')
  if taskId?
    paperId = $element.data('paper-id')
    taskCompleted = $element.data('task-completed')
    formHtml = """
      <form accept-charset="UTF-8" action="/papers/#{paperId}/tasks/#{taskId}" class="js-submit-on-change" data-remote="true" id="complete_task_#{taskId}" method="post">
        <div style="margin:0;padding:0;display:inline">
          <input name="utf8" type="hidden" value="✓">
          <input name="_method" type="hidden" value="patch">
        </div>
        <input name="task[completed]" type="hidden" value="0">
        <input id="task_#{taskId}_completed" name="task[completed]" type="checkbox" value="1" #{if taskCompleted then 'checked="checked"'}>
        <label for="task_#{taskId}_completed">Completed</label>
      </form>
    """
    footerContainer = $('footer .content')
    footerContainer.html formHtml
    form = $('form', footerContainer)
    @setupSubmitOnChange form, $('input[type="checkbox"]', form)

  contentContainer = $("##{overlayName}-content")
  container = $('main', overlay)
  contentContainer.children().appendTo(container)

  handler = (e) ->
    e.preventDefault()
    container.children().appendTo(contentContainer)
    overlay.hide()
    titleContainer.empty()
    footerContainer.empty()
    $('.close-overlay').unbind('click', handler)

  $('.close-overlay', overlay).on 'click', handler

  overlay.show()

Tahi.initOverlay = (element) ->
  $(element).on 'click', (e) ->
    e.preventDefault()
    Tahi.displayOverlay element
