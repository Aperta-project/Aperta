ETahi.PhaseHeaderView = Em.View.extend
  templateName: 'phase_header'
  classNames: ['column-header']
  classNameBindings: ['active']
  active: false

  focusIn: (e)->
    @set('active', true)

  phaseNameDidChange: (->
    # race condition with binding and cancel action? :(
    Em.run.later (->
      Tahi.utils.resizeColumnHeaders()
    ), 30
  ).observes('phase.name')

  actions:
    save: ->
      @set('active', false)
      @get('phase').save()

    cancel: ->
      @set('active', false)
      @get('phase').rollback()
