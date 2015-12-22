import Ember from 'ember';

/**
 *  A select box with additional "other..." option.
 *  When "other" is selected, a text input is displayed
 *
 *  ## How to Use
 *
 *  In your template:
 *
 *  ```
 *  {{#power-select-other options=names
 *                        value=name
 *                        as |text|}}
 *    {{text}}
 *  {{/power-select-other}}
 *  ```
**/

export default Ember.Component.extend({
  value: null, // passed in
  selectedValue: null, // internal state

  didReceiveAttrs() {
    this._super(...arguments);

    const value   = this.get('value');
    const options = this.get('options');

    if(options.contains(value)) {
      this.set('selectedValue', value);
    } else if(!Ember.isEmpty(value)) {
      this.set('selectedValue', this.get('otherText'));
    }
  },

  otherText: 'other...',

  _optionsWithOther: Ember.computed('options.[]', function() {
    let base = [];
    base.pushObjects(this.get('options'));
    base.pushObject(this.get('otherText'));
    return base;
  }),

  _otherOptionSelected: Ember.computed('selectedValue', function() {
    return this.get('selectedValue') === this.get('otherText');
  }),

  actions: {
    select(value) {
      this.set('selectedValue', value);
      this.set('value', value);
    }
  }
});
