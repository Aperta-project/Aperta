ETahi.ControlBarView = Ember.View.extend
  classNames: ['control-bar']
  controlBarSelector: '.control-bar'
  setupScroll: (->
    controlBar = $(@get('controlBarSelector'))

    $(window).on 'scroll.controlBar', ->
      scrolledAmount = $(this).scrollTop() - 30

      controlBar.css('backgroundColor', 'rgba(255,255,255, ' +
        (if scrolledAmount >= 90 then 0.9 else scrolledAmount/100)
      + ')')
  ).on('didInsertElement')

  teardownScroll: (->
    $(window).off 'scroll.controlBar'
  ).on('willDestroyElement')
