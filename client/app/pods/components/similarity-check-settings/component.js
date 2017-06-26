import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['similarity-check-settings'],
  selectableOptions: [
    {
      id: 'after_first_major_revise_decision',
      text: 'first major revision'
    },
    {
      id: 'after_first_minor_revise_decision',
      text: 'first minor revision'
    },
    {
      id: 'after_any_first_revise_decision',
      text: 'any first revision'
    }
  ],

  actions: {
    saveAnswer(newVal) {
      this.set('switchState', newVal);
    },
    clickOption (value) {
      this.set('submissionOption', value);
    },
    close() {
      this.attrs.close();
    }
  }
});
