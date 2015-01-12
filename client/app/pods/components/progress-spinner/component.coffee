`import Ember from 'ember'`

ProgressSpinnerComponent = Ember.Component.extend
  classNames: ['spinner-component']
  classNameBindings: ['visible']
  _options:
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

  visible: false
  size: 'small'
  color: 'green'

  _green: '#39a329'
  _blue: '#2d85de'

  _large:
    lines: 20
    radius: 30

  _small:
    lines: 7
    radius: 7

  show: (->
    options = Ember.merge(@get('_options'), @get('_' + @get('size')))
    options = Ember.merge(options, { color:  @get('_' + @get('color')) })

    @spinner = new Spinner(options).spin(@$().get(0))
  ).on('didInsertElement')

  teardown: (->
    @spinner.stop()
  ).on('willDestroyElement')

`export default ProgressSpinnerComponent`
