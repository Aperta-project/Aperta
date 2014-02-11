window.Tahi ||= {}

toCamel = (string) ->
  string.replace /(\-[a-z])/g, ($1) ->
    $1.toUpperCase().replace "-", ""

Tahi.overlay =
  init: (overlayName) ->
    $("[data-card-name='#{overlayName}']").on 'click', (e) ->
      Tahi.overlay.display e, overlayName

  display: (event, cardName) ->
    event.preventDefault()
    $target = $(event.target).closest '[data-card-name]'

    @renderCard(cardName, $target)

    cardId = $target.data 'taskId'
    currentState = {cardName: cardName, cardId: cardId}
    Tahi.utils.windowHistory().pushState currentState, null, "#{@defaultProps($target).overlayProps.paperPath}/tasks/#{cardId}"

  defaultProps: (element) ->
    turbolinksState = Tahi.utils.windowHistory().state

    taskTitle: element.data('taskTitle')
    overlayProps:
      paperTitle: element.data('paperTitle')
      paperPath: element.data('paperPath')
      taskPath: element.data('taskPath')
      taskTitle: element.data('taskTitle')
      taskCompleted: element.hasClass('completed')
      assignees: element.data('assignees')
      assigneeId: element.data('assigneeId')
      onOverlayClosed: (e) =>
        @hide(e, turbolinksState)

      onCompletedChanged: (event, data) ->
        $("[data-card-name='#{element.data('cardName')}']").toggleClass 'completed', data.completed

  hide: (event, turbolinksState=null) ->
    event?.preventDefault()
    $('html').removeClass 'noscroll'
    $('#overlay').hide()

    React.unmountComponentAtNode document.getElementById('overlay')

    if event?.type isnt "popstate"
      state = $.extend turbolinksState, hideOverlay: true
      Tahi.utils.windowHistory().pushState state, null, turbolinksState.url

  popstateOverlay: (e) =>
    history = Tahi.utils.windowHistory()
    if Tahi.utils.windowHistory().state?.cardName?
      cardName = Tahi.utils.windowHistory().state.cardName
      cardId = Tahi.utils.windowHistory().state.cardId
      targetElement = $("[data-task-id=#{cardId}]").first()
      Tahi.overlay.renderCard(cardName, targetElement)
    else if history.state?.hideOverlay
      Tahi.overlay.hide(e)

  renderCard: (cardName, targetElement) ->
    cardName = toCamel cardName
    component = Tahi.overlays[cardName].createComponent targetElement, Tahi.overlay.defaultProps(targetElement)

    React.renderComponent component, document.getElementById('overlay'), Tahi.initChosen

    $('html').addClass 'noscroll'
    $('#overlay').show()

$(window).bind 'popstate', Tahi.overlay.popstateOverlay
