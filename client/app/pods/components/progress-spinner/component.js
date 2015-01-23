import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['spinner-component'],
  classNameBindings: ['visible:spinner-component--visible'],
  defaultOptions: {
    className: 'spinner', // The CSS class to assign to the spinner
    color:     '#8ecb87', // #rgb or #rrggbb or array of colors
    corners:   1,         // Corner roundness (0..1)
    direction: 1,         // 1: clockwise, -1: counterclockwise
    hwaccel:   false,     // Whether to use hardware acceleration
    length:    0,         // The length of each line
    lines:     9,         // The number of lines to draw
    radius:    12,        // The radius of the inner circle
    rotate:    0,         // The rotation offset
    shadow:    false,     // Whether to render a shadow
    speed:     1.5,       // Rounds per second
    trail:     68,        // Afterglow percentage
    width:     7,         // The line thickness
    zIndex:    2e9
  },

  visible: false,
  color: 'green',
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

    var spinner = new Spinner(options).spin(this.$()[0]);
    this.set('spinner', spinner);
  }.on('didInsertElement'),

  teardown: function() {
    this.spinner.stop();
  }.on('willDestroyElement')
});
