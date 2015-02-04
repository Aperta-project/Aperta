`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

JournalFlowManagerView = Ember.View.extend
  columnCountDidChange: (->
    Ember.run.scheduleOnce('afterRender', this, Utils.resizeColumnHeaders)
  ).on('didInsertElement').observes('controller.model.flows.@each')

`export default JournalFlowManagerView`
