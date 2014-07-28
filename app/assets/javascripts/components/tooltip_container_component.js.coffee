ETahi.TooltipContainerComponent = Ember.Component.extend
  classNames: ['tahi-tooltip-container']
  mouseEnter: ->
    @set('showTooltip', true)
  mouseLeave: ->
    @set('showTooltip', false)
