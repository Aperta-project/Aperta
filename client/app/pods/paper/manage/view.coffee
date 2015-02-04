`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

PaperManageView = Ember.View.extend
  setupColumnHeights:(->
    Ember.run.scheduleOnce('afterRender', this, Utils.resizeColumnHeaders)
  ).on('didInsertElement').observes('controller.phases.@each')

`export default PaperManageView`
