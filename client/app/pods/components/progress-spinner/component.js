import Ember from 'ember';

/**
  ## How to Use

  In your template:

  ```
  {{progress-spinner visible=someBoolean}}
  ```

  In your controller or component toggle the boolean:

  ```
  this.set('someBoolean', true);
  ```
*/

export default Ember.Component.extend({
  classNames: ['spinner-component'],
  classNameBindings: ['visible:spinner-component--visible'],
  defaultOptions: {
    className: 'spinner', // The CSS class to assign to the spinner
    color:     '#39a329', // #rgb or #rrggbb or array of colors
    corners:   1,         // Corner roundness (0..1)
    direction: 1,         // 1: clockwise, -1: counterclockwise
    hwaccel:   false,     // Whether to use hardware acceleration
    length:    0,         // The length of each line
    lines:     7,         // The number of lines to draw
    radius:    7,        // The radius of the inner circle
    rotate:    0,         // The rotation offset
    shadow:    false,     // Whether to render a shadow
    speed:     1.5,       // Rounds per second
    trail:     68,        // Afterglow percentage
    width:     7,         // The line thickness
    zIndex:    2e9
  },

  /**
    Toggles visibility

    @property visible
    @type Boolean
    @default false
  */

  visible: false,

  /**
    Color. `green` or `blue` or `white`

    @property color
    @type String
    @default green
  */
  color: 'green',

  /**
    Size. `small` or `large`

    @property size
    @type String
    @default small
  */
  size: 'small',

  _green: '#39a329',
  _blue: '#2d85de',
  _white: '#ffffff',

  _large: {
    lines: 20,
    radius: 30
  },

  _small: {
    lines: 7,
    radius: 7
  },

  setup: function() {
    var options = Ember.merge(this.get('defaultOptions'), this.get('_' + this.get('size')));
        options = Ember.merge(options, { color:  this.get('_' + this.get('color')) });

    this.set( 'spinner', (new Spinner(options).spin(this.$()[0])) );
  }.on('didInsertElement'),

  teardown: function() {
    this.spinner.stop();
  }.on('willDestroyElement')
});
