import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'input',
  type: 'radio',
  attributeBindings: ['name', 'type', 'value', 'checked:checked', 'disabled', 'data-test-selector:data-test-selector'],

  value: null,
  selection: null,

  init() {
    this._super(...arguments);
    Ember.assert(
      'You must pass a value property to the RadioButtonComponent',
      this.get('value') !== null && this.get('value') !== undefined
    );
    Ember.assert(
      'You must pass a selection property to the RadioButtonComponent',
      this.attrs.hasOwnProperty('selection')
    );
  },

  checked: Ember.computed('selection', 'value', function() {
    // When determining if the radio button should be selected or not,
    // coerce both the html radio button form element value and any
    // current answer to strings.  This is to protect against the case
    // where the answered value in the database is being returned as
    // a non-string datatype (e.g., `true` instead of "true").  At
    // the html level, the value will always be a string, so do a
    // string-to-string comparison here to ensure that the radio button
    // is properly selected or not.

    let s = this.get('selection');

    if (Ember.isEmpty(s)) {
      return false; // a prior answer does not exist
    } else {
      return s.toString() === this.get('value').toString(); // compare
    }
  }),

  change() {
    this.get('action')(this.get('value'));
  }
});
