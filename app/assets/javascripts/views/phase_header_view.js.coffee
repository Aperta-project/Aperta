ETahi.PhaseHeaderView = Em.View.extend
  templateName: 'phase_header'
  classNames: ['column-header']
  classNameBindings: ['active']
  active: false

  focusIn: (e)->
    @set('active', true)

  phaseNameDidChange: (->
    Ember.run.schedule('afterRender' , this, ->
      Tahi.utils.resizeColumnHeaders()
    )
  ).observes('phase.name')

  actions:
    save: ->
      @set('active', false)
      @get('phase').save()

    cancel: ->
      @set('active', false)
      @get('phase').rollback()
