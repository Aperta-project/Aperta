`import Ember from 'ember'`

OverlayBackgroundView = Ember.View.extend
  willDestroyElement: ->
    $(this.get('element')).empty()

`export default OverlayBackgroundView`
