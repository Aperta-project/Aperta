import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'th',
  classNameBindings: ['active:sortable-table-header-active'],

  // attrs:
  text: null,
  sortProperty: null,
  sortAscending: null,
  activeSortProperty: null,

  active: Ember.computed('sortProperty', 'activeSortProperty', function() {
    return Ember.isEqual(this.get('sortProperty'), this.get('activeSortProperty'));
  }),

  click() {
    this.get('parentView').sortBy(this.get('sortProperty'));
  }
});
