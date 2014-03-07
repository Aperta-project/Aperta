Tahi.overlay =
  init: ->
    $("[data-card-name]").each (_, el) ->
      $el = $(el)
      overlayName = $el.data('cardName')
      $el.on 'click', (e) ->
        e.preventDefault()
        Tahi.overlay.display e, overlayName

  # This is the old implementation. Would be good to implement a common
  # interface using only #renderComponent, which is currently used for the Card component
  renderCard: (cardName, targetElement) ->
    props = Tahi.overlay.defaultProps(targetElement)
    cardName = Tahi.utils.toCamel cardName
    props.componentToRender = Tahi.overlays[cardName].Overlay
    component = Tahi.overlays.components.Overlay props

    React.renderComponent component, document.getElementById('overlay')

    $('html').addClass 'noscroll'
    $('#overlay').show()

  display: (event, cardName) ->
    event.preventDefault()
    $target = $(event.target).closest '[data-card-name]'

    @renderCard(cardName, $target)

    taskPath = $target.data('taskPath')
    currentState = {cardName: cardName, taskPath: taskPath}
    Tahi.utils.windowHistory().pushState currentState, null, taskPath

  renderComponent: (e, overlayProps) ->
    turbolinksState = Tahi.utils.windowHistory().state
    overlayProps.onOverlayClosed = (e) =>
      @hide(e, turbolinksState)

    component = Tahi.overlays.components.Overlay overlayProps
    React.renderComponent component, document.getElementById('overlay')

    $('html').addClass 'noscroll'
    $('#overlay').show()

    taskPath = overlayProps.taskPath
    currentState = {cardName: overlayProps.cardName, taskPath: taskPath}
    Tahi.utils.windowHistory().pushState currentState, null, taskPath

  defaultProps: (element) ->
    turbolinksState = Tahi.utils.windowHistory().state

    cardName: $(element).data('cardName')
    taskPath: element.data('taskPath')

    onOverlayClosed: (e) =>
      @hide(e, turbolinksState)

    onCompletedChanged: (event, data) ->
      $("[data-task-id='#{element.data('taskId')}'][data-card-name='#{element.data('cardName')}']").toggleClass 'completed', data.completed

  hide: (event, turbolinksState=null) ->
    event?.preventDefault()
    $('html').removeClass 'noscroll'
    $('#overlay').hide()

    React.unmountComponentAtNode document.getElementById('overlay')

    if event?.type isnt "popstate" && turbolinksState?
      state = $.extend turbolinksState, hideOverlay: true
      Tahi.utils.windowHistory().pushState state, null, turbolinksState.url

  popstateOverlay: (e) =>
    history = Tahi.utils.windowHistory()
    if Tahi.utils.windowHistory().state?.cardName?
      cardName = Tahi.utils.windowHistory().state.cardName
      taskPath = Tahi.utils.windowHistory().state.taskPath
      targetElement = $("[data-task-path='#{taskPath}']").first()
      Tahi.overlay.renderCard(cardName, targetElement)
    else if history.state?.hideOverlay
      Tahi.overlay.hide(e)

$(window).bind 'popstate', Tahi.overlay.popstateOverlay
