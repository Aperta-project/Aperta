import Ember from 'ember';
const { computed } = Ember;

export default Ember.Component.extend({
  selection: null,
  index: null,
  yesValue: true,
  noValue: false,
  yesLabel: 'Yes',
  noLabel: 'No',

  idYes: computed('name', function() {
    return `${this.elementId}-${this.get('name')}-yes`;
  }),

  idNo: computed('name', function() {
    return `${this.elementId}-${this.get('name')}-no`;
  }),

  yesChecked: computed('selection', 'yesValue', function() {
    return Ember.isEqual(this.get('yesValue'), this.get('selection'));
  }),

  noChecked: computed('selection', 'noValue', function() {
    return Ember.isEqual(this.get('noValue'), this.get('selection'));
  }),

  actions: {
    selectYes() {
      this.set('selection', this.get('yesValue'));
      this.sendAction('yesAction');
    },

    selectNo() {
      this.set('selection', this.get('noValue'));
      this.sendAction('noAction');
    }
  }
});
