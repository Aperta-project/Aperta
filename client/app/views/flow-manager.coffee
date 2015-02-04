`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

FlowManagerView = Ember.View.extend
  columnCountDidChange: (->
    Ember.run.scheduleOnce('afterRender', this, Tahi.utils.resizeColumnHeaders)
  ).on('didInsertElement').observes('controller.model.@each')

`export default FlowManagerView`
