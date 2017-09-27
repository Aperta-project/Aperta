import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-content-radio'],
  tagName: 'fieldset',
  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  },

  init() {
    this._super(...arguments);

    if(this.get('isText')) {
      Ember.assert(
        `the content must define an array of possibleValues
      that contains at least one object with the shape { label, value } `,
        Ember.isPresent(this.get('content.possibleValues'))
      );
    }
  },

  isText: Ember.computed('content.valueType', function() {
    return (this.get('content.valueType') === 'text');
  }),

  actions: {
    valueChanged(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal);
      }
    }
  }
});
