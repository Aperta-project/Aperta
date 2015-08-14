`import Ember from "ember";`
`import Utils from "tahi/services/utils";`

Component = Ember.Component.extend
  classNames: ["dataset"]

  uniqueName: (->
    "funder-had-influence-#{Utils.generateUUID()}"
  ).property()

  _saveModel: ->
    @get("model").save()

  change: (e) ->
    Ember.run.debounce(@, @_saveModel, 400)

  actions:
    removeFunder: (disabled) ->
      return if (@get('disabled') == true)
      @get("model").destroyRecord()

`export default Component;`
