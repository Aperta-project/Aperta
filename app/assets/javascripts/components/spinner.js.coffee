ETahi.ProgressSpinnerComponent = Ember.View.extend
  classNames: ['spinner-component']
  classNameBindings: ['visible']
  opts:( ->
    lines: 9 # The number of lines to draw
    length: 0 # The length of each line
    width: 7 # The line thickness
    radius: 12 # The radius of the inner circle
    corners: 1 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    direction: 1 # 1: clockwise, -1: counterclockwise
    color: '#8ecb87' # #rgb or #rrggbb or array of colors
    speed: 1.5 # Rounds per second
    trail: 68 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: false # Whether to use hardware acceleration
    className: 'spinner' # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
  ).property()

  visible: false

  show: (->
    @spinner = new Spinner(@get('opts')).spin(@$().get(0))
  ).on('didInsertElement')

  teardown: (->
    @spinner.stop()
  ).on('willDestroyElement')
