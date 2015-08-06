import Ember from 'ember';

export default Ember.Component.extend({
  startPicker: null,
  endPicker: null,

  registerPicker(datePicker) {
    this.set(datePicker.get('role'), datePicker);
  },

  dateChanged() {
    this.enforceConsistency();
  },

  enforceConsistency() {
    Ember.run(()=> {
      if (this.get('startPicker.ready') && this.get('endPicker.ready')) {
        this.get('endPicker').setStartDate(this.get('startPicker.date'));
        this.get('startPicker').setEndDate(this.get('endPicker.date'));
      }
    });
  }
});
