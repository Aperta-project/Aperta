`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

ManuscriptManagerTemplateEditView = Ember.View.extend
  setupColumnResizing: (->
    Ember.run.scheduleOnce('afterRender', this, Utils.resizeColumnHeaders)
  ).on('didInsertElement').observes('controller.editMode')

`export default ManuscriptManagerTemplateEditView`
