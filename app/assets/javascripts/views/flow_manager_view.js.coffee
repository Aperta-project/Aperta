ETahi.FlowManagerView = Ember.View.extend
  columnCountDidChange: (->
    Em.run.next ->
      Tahi.utils.resizeColumnHeaders()
  ).on('didInsertElement').observes('controller.model.@each')
