import Ember from 'ember';

export default Ember.TextField.extend({
  tagName: 'input',
  classNames: ['timepicker', 'form-control', 'timepicker-field'],
  ready: false,
  time: null,

  _setup: Ember.on('didInsertElement', function() {

    let $picker = this.$().timepicker();

    $picker.on('changeTime', (event) => {
      this.updateTime(event);
    });

    this.set('$picker', $picker);
    this.set('ready', true);
  }),

  change: function() {
    this.updateTime(this.element.value);
  },

  updateTime: function(selectedTime) {
    this.set('time', selectedTime);
    this.sendAction('timeChanged', selectedTime);
  },
});
