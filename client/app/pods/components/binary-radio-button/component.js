import Ember from 'ember';

export default Ember.Component.extend({
  selection: null,
  index: null,
  yesValue: true,
  noValue: false,
  yesLabel: 'Yes',
  noLabel: 'No',

  idYes: function() {
    return this.get('name') + '-yes';
  }.property('name'),

  idNo: function() {
    return this.get('name') + '-no';
  }.property('name'),

  yesChecked: function() {
    return this.get('yesValue') === this.get('selection');
  }.property('selection', 'yesValue'),

  noChecked: function() {
    return this.get('noValue') === this.get('selection');
  }.property('selection', 'noValue'),

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
