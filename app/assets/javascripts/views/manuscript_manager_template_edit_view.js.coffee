ETahi.ManuscriptManagerTemplateEditView = Ember.View.extend
  setupColumnResizing: (->
    Ember.run.scheduleOnce('afterRender', this, Tahi.utils.resizeColumnHeaders)
  ).on('didInsertElement').observes('controller.editMode')
