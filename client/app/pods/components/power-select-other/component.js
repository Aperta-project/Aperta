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

const { computed, observer } = Ember;

export default Ember.Component.extend({
  classNameBindings: [
    ':power-select-other',
    'errorPresent:error',
    '_otherOptionSelected:power-select-other--other-selected'
  ],
  errorPresent: Ember.computed.notEmpty('errors'),

  /**
   *  @property value
   *  @type String | Number
   *  @default null
   *  @required
  **/
  value: null,

  /**
   *  Switch between plain text input or content-editable
   *  for `other` option
   *
   *  @property allowOtherFormatting
   *  @type Boolean
   *  @default false
   *  @optional
  **/
  allowOtherFormatting: false,

  /**
   *  Text to be used for other
   *
   *  @property otherText
   *  @type String
   *  @default 'other...'
   *  @optional
  **/
  otherText: 'other...',

  /**
   *  Enable/disable power-select component search
   *
   *  @property searchEnabled
   *  @type Boolean
   *  @default false
   *  @optional
  **/
  searchEnabled: false,

  /**
   *  Placeholder for power-select component
   *
   *  @property selectPlaceholder
   *  @type String
   *  @default ''
   *  @optional
  **/
  selectPlaceholder: '',

  /**
   *  Placeholder for input
   *
   *  @property inputPlaceholder
   *  @type String
   *  @default ''
   *  @optional
  **/
  inputPlaceholder: '',

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

  _optionsWithOther: computed('options.[]', function() {
    let base = [];
    base.pushObjects(this.get('options'));
    base.pushObject(this.get('otherText'));
    return base;
  }),

  _otherOptionSelected: computed('selectedValue', function() {
    return this.get('selectedValue') === this.get('otherText');
  }),


  _otherWasSelected: observer('_otherOptionSelected', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      this.$('.power-select-other-input').focus();
    });
  }),

  actions: {
    select(value) {
      this.set('selectedValue', value);

      if(value === this.get('otherText')) {
        this.set('value', null);
        return;
      }

      this.set('value', value);
    },

    otherTrigger() {
      this.set('selectedValue', null);
      this.set('value', null);
      Ember.run.scheduleOnce('afterRender', ()=> {
        this.$('.ember-power-select-trigger').mousedown();
      });
    }
  }
});
