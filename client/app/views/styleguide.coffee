`import Ember from 'ember'`

StyleguideView = Ember.View.extend
  didInsertElement: ->
    @_super()
    Ember.run.scheduleOnce 'afterRender', this, @afterRenderEvent

  afterRenderEvent: ->
    $('#card-overlays > a').click ->
      $(this).next().removeClass 'hide'

    # Hide all the overlays to start
    $('*[overlay]').children().hide()
    $('.toggle-link').click ->
      $(this).parents('.ui-element').find('*[element-name]').children().show()

    $('.overlay .overlay-close-button, .overlay-close-x').click ->
      $(this).parents('.ui-element').find('*[element-name]').children().hide()

    # Repositions Toolbar
    $('.control-bar').css 'position', 'relative'
    # Manually Adjust Workflow styles
    $('.columns').css 'position', 'initial'
    $('.columns').css 'height', '450px'
    # Enable the Show Source Toggle Buttons
    # $("*[data-toggle]").click(function() {
    #   $($(this).attr("href")).toggle();
    # });
    $('#toggle-all-source').click ->
      $('.collapse').toggle()

    setScrollWindow = ->
      $('.col-md-10').height ->
        $(window).height() - 125
      $('.col-md-10').css 'overflow-y', 'scroll'

    $(window).resize setScrollWindow()
    # TODO consider doing it another way that is less tightly coupled to selectors.
    $('.show-child-mmt-thumbnail .mmt-thumbnail .mmt-thumbnail-overlay--edit-options').show()
    $('.show-child-confirm-destroy .mmt-thumbnail-overlay--confirm-destroy').show()

`export default StyleguideView`
