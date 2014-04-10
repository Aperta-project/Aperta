ETahi.OverlayBackgroundView = Ember.View.extend
  willDestroyElement: ->
    $(this.get('element')).empty()
