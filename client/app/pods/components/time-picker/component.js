import Ember from 'ember';

export default Ember.TextField.extend({
  tagName: 'input',
  classNames: ['timepicker', 'form-control', 'timepicker-field'],
  ready: false,
  time: null,

  didInsertElement() {

    let $picker = this.$().timepicker();

    $picker.on('changeTime', (event) => {
      this.updateTime(event);
    });

    this.set('$picker', $picker);
    this.set('ready', true);
  },

  change() {
    this.updateTime(this.element.value);
  },

  updateTime(selectedTime) {
    this.set('time', selectedTime);
    this.sendAction('timeChanged', selectedTime);
  },
});
