import Ember from 'ember';

// Receives info on current order state
//   activeorderBy:  null,
//   activeOrderDir: null,
//
// Calls a closure action when clicked, saying what the new
// order state should be:
//   it's configured sort field (orderBy)
//   the appropriate new sort direction 
//
// Intended to be used to call out an action that will trigger a model
// collection reload, which will trigger re reload of the template.
// This means that state binding, is not only unnecessary, it is not desired,
// since we want the response from server to set the state
export default Ember.Component.extend({
  tagName: 'a',
  classNameBindings: [
    'active:sort-link-active:sort-link',
  ],
  title:           'testing',

  // attrs
  text:           null,
  orderBy:        null,
  activeorderBy:  null,
  activeOrderDir: null,

  // action
  sortAction:     null,

  isAsc: Ember.computed('activeorderBy', function(){
    return Ember.isEqual(this.get('activeorderBy'), 'asc');
  }),

  orderDir: Ember.computed('isAsc', function(){
    if (this.get('active')) {
      return this.get('isAsc') ? 'desc' : 'asc';
    } else {
      return 'asc';
    }
  }),

  active: Ember.computed('orderBy', 'activeorderBy', function() {
    return Ember.isEqual(this.get('orderBy'), this.get('activeorderBy'));
  }),

  click() {
    this.get('sortAction')(this.get('orderBy'), this.get('orderDir'));
  }
});
