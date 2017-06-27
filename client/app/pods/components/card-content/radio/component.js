import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-radio'],

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  },

  init() {
    this._super(...arguments);

    if(this.get('content.valueType') === 'text') {
      Ember.assert(
        `the content must define an array of possibleValues
      that contains at least one object with the shape { label, value } `,
        Ember.isPresent(this.get('content.possibleValues'))
      );
    }
  },

  radioTemplate: Ember.computed('content.valueType', function() {
    if(this.get('content.valueType') === 'text') {
      return 'components/card-content/radio/radio-text';
    }
    else {
      return 'components/card-content/radio/radio-boolean';
    }
  }),

  yesValue: true,
  noValue: false,
  yesLabel: 'Yes',
  noLabel: 'No',

  actions: {
    valueChanged(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal);
      }
    }
  }
});
