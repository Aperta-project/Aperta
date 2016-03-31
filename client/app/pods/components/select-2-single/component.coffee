`import Ember from 'ember'`
`import Select2Component from 'tahi/pods/components/select-2/component'`

Select2SingleComponent = Select2Component.extend
  setRemoteSource: (->
    this.set('selectedData', null);
    @repaint()
  ).observes('remoteSource')

  setSelectedData: (->
    @.$().select2('val', @get('selectedData'))
  ).observes('selectedData')

  initSelection: (el, callback) ->
    (new Ember.RSVP.Promise (resolve) =>
      resolve(@get('selectedData'))
    ).then callback

`export default Select2SingleComponent`
