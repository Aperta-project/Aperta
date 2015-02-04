`import Ember from 'ember'`

SavesDelayed = Ember.Mixin.create
  needs: ['application']
  delayedSave: Ember.computed.alias('controllers.application.delayedSave')

  saveDelayed: ->
    @set('delayedSave', true)
    Ember.run.debounce(@, @saveModel, 500)

  saveModel: ->
    unless @get('saveInFlight')
      @set('saveInFlight', true)
      @get('model').save().finally =>
        @set('saveInFlight', false)
        @set('delayedSave', false)

  actions:
    saveModel: ->
      @saveDelayed()

`export default SavesDelayed`
