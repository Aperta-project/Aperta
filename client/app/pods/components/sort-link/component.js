import Ember from 'ember';

// Purpose: to emit a closure action, passing:
//   it's configured sort field
//   the appropriate sort direction
//
// Intended to be used to call out an action that will trigger a model
// collection reload, which will trigger re reload of the template.
// This means that var binding, is not only unnecessary, it is not desired,
// since we want the response from server to set the state
export default Ember.Component.extend({
  tagName: 'a',
  classNameBindings: [
    'active:sort-link-active:sort-link',
  ],

  // attrs:
  text: null,
  sortProperty: null,
  activeSortProperty: null,
  activeSortDir: null,

  sortAscending: null,

  active: Ember.computed('sortProperty', 'activeSortProperty', function() {
    return Ember.isEqual(this.get('sortProperty'), this.get('activeSortProperty'));
  }),

  click() {
    this.get('parentView').sortBy(this.get('sortProperty'));
  }
});
