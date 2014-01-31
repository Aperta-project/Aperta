window.Tahi ||= {}

Tahi.init = ->
  Tahi.papers.init()
  Tahi.overlays.authors.init()
  Tahi.overlays.figures.init()
  Tahi.overlays.newCard.init()
  Tahi.overlays.declarations.init()
  Tahi.overlays.registerDecision.init()
  Tahi.overlays.uploadManuscript.init()
  Tahi.overlays.techCheck.init()
  Tahi.overlays.reviewerReport.init()
  Tahi.overlays.assignEditor.init()
  Tahi.overlays.assignReviewers.init()

  for form in $("form.js-submit-on-change[data-remote='true']")
    @setupSubmitOnChange $(form), $('select, input[type="radio"], input[type="checkbox"], textarea', form)

  for element in $('[data-overlay-name]')
    Tahi.initOverlay(element)

  Tahi.initChosen()
  Tahi.escapeKeyClosesOverlay()

Tahi.escapeKeyClosesOverlay = ->
  $('body').on 'keyup', (e) ->
    if e.which == 27
      $('.close-overlay').click()

Tahi.initChosen = ->
  $('.chosen-select').chosen
    width: '200px'

Tahi.setupSubmitOnChange = (form, elements, options) ->
  form.on 'ajax:success', options?.success
  elements.on 'change', (e) ->
    form.trigger 'submit.rails'

Tahi.displayOverlay = (element) ->
  overlay = $('#overlay')

  $element = $(element)
  overlayName = $element.data('overlay-name')
  overlayTitle = $element.data('overlay-title')

  paperId = $element.data('paper-id')
  titleContainer = $('header h2', overlay)
  titleContainer.html $("<a href='/papers/#{paperId}'>#{overlayTitle}</a>")

  taskId = $element.data('task-id')
  if taskId?
    taskCompleted = $element.data('task-completed')
    formHtml = """
      <div class="assignee-drop-down" />
      <div class="completed-checkbox">
        <form accept-charset="UTF-8" action="/papers/#{paperId}/tasks/#{taskId}" class="js-submit-on-change" data-remote="true" id="complete_task_#{taskId}" method="post">
          <div style="margin:0;padding:0;display:inline">
            <input name="utf8" type="hidden" value="✓">
            <input name="_method" type="hidden" value="patch">
          </div>
          <input name="task[completed]" type="hidden" value="0">
          <input id="task_#{taskId}_completed" name="task[completed]" type="checkbox" value="1" #{if taskCompleted then 'checked="checked"'}>
          <label for="task_#{taskId}_completed">Completed</label>
        </form>
      </div>
    """
    footerContainer = $('footer .content')
    footerContainer.html formHtml
    form = $('form', footerContainer)
    @setupSubmitOnChange form, $('input[type="checkbox"]', form)

  contentContainer = $("##{overlayName}-content")
  container = $('main', overlay)
  contentContainer.children().appendTo(container)

  $('html').addClass 'noscroll'

  handler = (e) ->
    e.preventDefault()
    container.children().appendTo(contentContainer)
    $('html').removeClass 'noscroll'
    overlay.hide()
    titleContainer.empty()
    isCompleted = $('form input[type="checkbox"]', footerContainer).is(':checked')
    $element.data 'task-completed', isCompleted
    $element.toggleClass 'completed', isCompleted
    footerContainer.empty()
    $('.close-overlay').unbind('click', handler)

  $('.close-overlay', overlay).on 'click', handler

  overlay.show()

Tahi.initOverlay = (element) ->
  $(element).on 'click', (e) ->
    e.preventDefault()
    Tahi.displayOverlay element
