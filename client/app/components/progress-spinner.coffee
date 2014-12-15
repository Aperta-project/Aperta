`import Ember from 'ember'`

ProgressSpinnerComponent = Ember.Component.extend
  classNames: ['spinner-component']
  classNameBindings: ['visible']
  options:
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

  bodyOptions:
    lines: 20
    radius: 30

  headerOptions:
    lines: 7
    radius: 7
    className: 'body-spinner'

  visible: false

  bodySpinner: false
  headerSpinner: false

  show: (->
    options = @get('options')
    if @get('bodySpinner')
      options = Ember.merge(options, @get('bodyOptions'))
    if @get('headerSpinner')
      options = Ember.merge(options, @get('headerOptions'))

    @spinner = new Spinner(options).spin(@$().get(0))
  ).on('didInsertElement')

  teardown: (->
    @spinner.stop()
  ).on('willDestroyElement')

`export default ProgressSpinnerComponent`
