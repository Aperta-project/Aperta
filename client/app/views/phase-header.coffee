`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

PhaseHeaderView = Ember.View.extend
  templateName: 'phase_header'
  classNames: ['column-header']
  classNameBindings: ['active']
  active: false
  previousContent: null

  focusIn: (e)->
    @set('active', true)
    if $(e.target).attr('contentEditable')
      @set('oldPhaseName', @get('phase.name'))

  phaseNameDidChange: (->
    Ember.run.scheduleOnce('afterRender', this, Utils.resizeColumnHeaders)
  ).observes('phase.name')

  currentHeaderHeight: Ember.computed 'phase.name', -> @$().find('.column-title').height()

  input: (e) ->
    if @get('currentHeaderHeight') <= 58
      @set 'previousContent', @get('phase.name')
    else
      @set 'phase.name', @get('previousContent')

  actions:
    save: ->
      @set('active', false)
      @get('controller').send('savePhase', @get('phase'))

    cancel: ->
      @set('active', false)
      @get('controller').send('rollbackPhase', @get('phase'), @get('oldPhaseName'))
      Ember.run.scheduleOnce('afterRender', this, Utils.resizeColumnHeaders)

`export default PhaseHeaderView`
