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

  preview: false,

  initial: Ember.computed.reads('content.initial'),
  min: Ember.computed.reads('content.min'),
  max: Ember.computed.reads('content.max'),

  // lowerBound: Ember.computed.reads('content.min'),
  inRange: Ember.computed('content.min', 'content.max', function () {return this.get('lowerBound') < this.get('upperBound');}),
  upperBound: Ember.computed('content.max', function () {return 1 + this.get('content.max');}),
  lowerBound: Ember.computed('content.initial', 'content.min', function () {
    let initial = this.get('content.initial'), min = this.get('content.min');
    return (initial && min) ? Math.max(Math.min(initial, min), 0) : (initial || min || 0);
  }),

  init() {
    this._super(...arguments);
    // debugger;
  }

});
