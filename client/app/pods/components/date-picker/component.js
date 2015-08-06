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
      autoclose: true
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
    this.get('$picker').datepicker('setEndDate', dateString);
  }
});
