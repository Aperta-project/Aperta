ETahi.ControlBarView = Ember.View.extend
  classNames: ['control-bar']
  controlBarSelector: '.control-bar'
  scrollSelector: '#tahi-container'
  setupScroll: (->
    controlBar = $(@get('controlBarSelector'))

    $(@get('scrollSelector')).on 'scroll.controlBar', ->
      scrolledAmount = $(this).scrollTop() - 30

      controlBar.css('backgroundColor', 'rgba(255,255,255, ' +
        (if scrolledAmount >= 90 then 0.9 else scrolledAmount/100)
      + ')')
  ).on('didInsertElement')

  teardownScroll: (->
    $(@get('scrollSelector')).off 'scroll.controlBar'
  ).on('willDestroyElement')
