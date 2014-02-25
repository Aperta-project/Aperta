window.Tahi ||= {}

Tahi.utils =
  windowHistory: ->
    window.history
  resizeH2: (selector) ->
    heights = $(selector).find('h2').map ->
      $(this).outerHeight(true)
    max = Math.max.apply(Math, heights);
    console.log(max);
    $(selector).css('height', max);
