ETahi.PaperManageView = Ember.View.extend
  setupColumnHeights:(->
    Ember.run.scheduleOnce('afterRender', this, Tahi.utils.resizeColumnHeaders)
  ).on('didInsertElement').observes('controller.phases.@each')
