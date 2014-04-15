ETahi.PaperManageView = Ember.View.extend
  setupColumnHeights:(->
    Tahi.utils.resizeColumnHeaders()
  ).on('didInsertElement').observes('controller.phases.@each')
