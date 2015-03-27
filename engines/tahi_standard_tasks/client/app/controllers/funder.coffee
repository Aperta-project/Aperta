`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`
`import SavesDelayed from 'tahi/mixins/controllers/saves-delayed'`

FunderController = Ember.ObjectController.extend SavesDelayed,
  uniqueName: (->
    "funder-had-influence-#{Utils.generateUUID()}"
  ).property()

  actions:
    funderDidChange: ->
      #saveModel is implemented in ETahi.SavesDelayed
      @send('saveModel')

    removeFunder: ->
      @get('model').destroyRecord()

`export default FunderController`
