import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['segmented-button'],
  classNameBindings: ['active:segmented-button--active'],

  value: null,

  active: function() {
    return this.get('value') === this.get('parentView.selectedValue');
  }.property('value', 'parentView.selectedValue'),

  click: function() {
    this.get('parentView').valueSelected(this.get('value'));
  }
});
