window.Tahi ||= {}

Tahi.overlay =
  init: (overlayName, constructComponentCallback) ->
    $("[data-card-name='#{overlayName}']").on 'click', (e) ->
      Tahi.overlay.display e, constructComponentCallback

  display: (event, constructComponentCallback) ->
    event.preventDefault()

    $target = $(event.target).closest '[data-card-name]'
    component = constructComponentCallback $target, @defaultProps($target)
    React.renderComponent component, document.getElementById('overlay'), Tahi.initChosen
    $('html').addClass 'noscroll'
    $('#overlay').show()

  defaultProps: (element) ->
    paperTitle: element.data('paperTitle')
    paperPath: element.data('paperPath')
    taskPath: element.data('taskPath')
    taskTitle: element.data('taskTitle')
    taskCompleted: element.hasClass('completed')
    assignees: element.data('assignees')
    assigneeId: element.data('assigneeId')
    onOverlayClosed: (e) =>
      @hide(e)
      # we default to true,
      # so refreshOnClose is true for all values except false
      refreshOnClose = element.data('refreshOnClose') != false
      Turbolinks.visit(window.location) if refreshOnClose
    onCompletedChanged: (event, data) ->
      $("[data-card-name='#{element.data('cardName')}']").toggleClass 'completed', data.completed

  hide: (e) ->
    e?.preventDefault()
    $('html').removeClass 'noscroll'
    $('#overlay').hide()
    React.unmountComponentAtNode document.getElementById('overlay')
