ETahi.IndexView = Ember.View.extend
  listenForPapers: (->
    @get('controller').on 'papersDidLoad', this, =>
      Em.run.later ( => @setupTooltips() ), 150

    @setupTooltips()
  ).on('didInsertElement')

  stopListeningForPapers: (->
    @get('controller').off('papersDidLoad', @)
  ).on('willDestroyElement')

  setupTooltips: ->
    $('.link-tooltip').tooltip().removeClass('link-tooltip')
