import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'a',
  classNames: ['date-picker-link'],
  date: null,
  calendarIcon: 'fa-calendar',
  linkText: null,

  _setup: Ember.on('didInsertElement', function() {
    let $picker = this.$().datepicker({
      autoclose: true,
      startDate: this.get('startDate') || new Date(),
    });

    $picker.on('changeDate', (event)=> {
      this.sendAction('dateChanged', event.date);
    });
  }),
});
