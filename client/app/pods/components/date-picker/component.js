import Ember from 'ember';

export default Ember.TextField.extend({
  tagName: 'input',
  classNames: ['datepicker', 'form-control', 'datepicker-field'],
  ready: false,
  date: null,

  _setup: Ember.on('didInsertElement', function() {
    const partOfGroup = !!this.get('group');

    if(partOfGroup) {
      this.get('group').registerPicker(this);
    }

    this.set('value', this.get('date'));

    let $picker = this.$().datepicker({
      autoclose: true,
      endDate: this.get('endDate')
    });

    $picker.on('changeDate', (event)=> {
      this.set('date', event.format());
      if(partOfGroup) { this.get('group').dateChanged(); }
    });

    $picker.on('clearDate', ()=> {
      this.set('date', null);
      if(partOfGroup) { this.get('group').dateChanged(); }
    });

    this.set('$picker', $picker);
    this.set('ready', true);
  }),

  setStartDate(dateString) {
    this.get('$picker').datepicker('setStartDate', dateString);
  },

  setEndDate(dateString) {
    let newDate = dateString;
    let endDate = this.get('endDate');

    // if developer has set an endDate and newDate
    // is empty from another field being cleared
    if(endDate && Ember.isEmpty(newDate)) {
      this.get('$picker').datepicker('setEndDate', endDate);
      return;
    }

    // If the developer set an endDate, don't let
    // the newDate go into the future
    let pastEndDate = moment(newDate).isAfter(endDate);
    if(pastEndDate) {
      this.get('$picker').datepicker('setEndDate', endDate);
      return;
    }

    this.get('$picker').datepicker('setEndDate', dateString);
  }
});
