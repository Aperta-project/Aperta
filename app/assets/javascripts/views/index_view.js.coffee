ETahi.IndexView = Ember.View.extend
  setupTooltip:(->
    $('.dashboard-paper-title').tooltip()
  ).on('didInsertElement')
