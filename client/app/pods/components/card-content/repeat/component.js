import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-repeat'],

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool,
    inRange: PropTypes.bool
  },

  previewState: true,

  initial: Ember.computed.reads('content.initial'),
  min: Ember.computed.reads('content.min'),
  max: Ember.computed.reads('content.max'),

  lowerBound: Ember.computed.reads('content.min'),
  upperBound: Ember.computed('content.max', function () {return this.get('content.max') + 1;}),
  inRange: Ember.computed('content.min', 'content.max', function () {return this.get('content.min') < this.get('content.max');})
});
