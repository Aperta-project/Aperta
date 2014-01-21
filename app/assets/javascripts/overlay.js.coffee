window.Tahi ||= {}

Tahi.overlay =
  init: (overlayName, constructComponentCallback) ->
    $("[data-card-name='#{overlayName}']").on 'click', (e) ->
      Tahi.overlay.display e, constructComponentCallback

  display: (event, constructComponentCallback) ->
    event.preventDefault()

    $target = $(event.target)
    component = constructComponentCallback $target, @defaultProps($target)
    React.renderComponent component, document.getElementById('new-overlay'), Tahi.initChosen
    $('#new-overlay').show()

  defaultProps: (element) ->
    paperTitle: element.data('paperTitle')
    paperPath: element.data('paperPath')
    taskPath: element.data('taskPath')
    taskCompleted: element.hasClass('completed')
    onCompletedChanged: (event, data) ->
      $("[data-card-name='#{element.data('cardName')}']").toggleClass 'completed', data.completed

  hide: (e) ->
    e?.preventDefault()
    $('#new-overlay').hide()
    React.unmountComponentAtNode document.getElementById('new-overlay')
