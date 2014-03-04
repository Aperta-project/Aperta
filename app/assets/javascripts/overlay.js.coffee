toCamel = (string) ->
  string.replace /(\-[a-z])/g, ($1) ->
    $1.toUpperCase().replace "-", ""

Tahi.overlay =
  init: ->
    $("[data-card-name]").each (_, el) ->
      $el = $(el)
      overlayName = $el.data('cardName')
      $el.on 'click', (e) ->
        e.preventDefault()
        Tahi.overlay.display e, overlayName

  display: (event, cardName) ->
    event.preventDefault()
    $target = $(event.target).closest '[data-card-name]'

    @renderCard(cardName, $target)

    taskHref = $target.attr('href')
    currentState = {cardName: cardName, taskHref: taskHref}
    Tahi.utils.windowHistory().pushState currentState, null, taskHref

  defaultProps: (element) ->
    turbolinksState = Tahi.utils.windowHistory().state

    taskPath: element.attr('href')
    onOverlayClosed: (e) =>
      @hide(e, turbolinksState)

    onCompletedChanged: (event, data) ->
      $("[data-task-id='#{element.data('taskId')}'][data-card-name='#{element.data('cardName')}']").toggleClass 'completed', data.completed

  hide: (event, turbolinksState=null) ->
    event?.preventDefault()
    $('html').removeClass 'noscroll'
    $('#overlay').hide()

    React.unmountComponentAtNode document.getElementById('overlay')

    if event && event?.type isnt "popstate"
      state = $.extend turbolinksState, hideOverlay: true
      Tahi.utils.windowHistory().pushState state, null, turbolinksState.url

  popstateOverlay: (e) =>
    history = Tahi.utils.windowHistory()
    if Tahi.utils.windowHistory().state?.cardName?
      cardName = Tahi.utils.windowHistory().state.cardName
      taskHref = Tahi.utils.windowHistory().state.taskHref
      targetElement = $("[href='#{taskHref}']").first()
      Tahi.overlay.renderCard(cardName, targetElement)
    else if history.state?.hideOverlay
      Tahi.overlay.hide(e)

  renderCard: (cardName, targetElement) ->
    props = Tahi.overlay.defaultProps(targetElement)
    cardName = toCamel cardName
    props.componentToRender = Tahi.overlays[cardName].Overlay
    component = Tahi.overlays.components.Overlay props

    React.renderComponent component, document.getElementById('overlay')

    $('html').addClass 'noscroll'
    $('#overlay').show()

$(window).bind 'popstate', Tahi.overlay.popstateOverlay
