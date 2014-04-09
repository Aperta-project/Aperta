ETahi.PaperManageView = Ember.View.extend
  setupColumnHeights:(->
    Tahi.utils.bindColumnResize()
    Tahi.utils.resizeColumnHeaders()
  ).on('didInsertElement').observes('controller.model.phases.@each.name')
