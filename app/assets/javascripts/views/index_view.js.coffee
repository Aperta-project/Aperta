ETahi.IndexView = Ember.View.extend
  setupTooltip:(->
    $('.link-tooltip').tooltip()
  ).on('didInsertElement')
