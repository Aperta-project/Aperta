ETahi.JournalFlowManagerView = Ember.View.extend
  columnCountDidChange: (->
    Ember.run.scheduleOnce('afterRender', this, Tahi.utils.resizeColumnHeaders)
  ).on('didInsertElement').observes('controller.model.flows.@each')
