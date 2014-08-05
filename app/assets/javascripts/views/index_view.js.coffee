ETahi.IndexView = Ember.View.extend
  listenForPapers: (->
    @get('controller').on('papersDidLoad', @, @setupTooltips)
    @setupTooltips()
  ).on('didInsertElement')

  stopListeningForPapers: (->
    @get('controller').off('papersDidLoad', @, @setupTooltips)
  ).on('willDestroyElement')

  setupTooltips: ->
    $('.link-tooltip').tooltip().removeClass('link-tooltip')
