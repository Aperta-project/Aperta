import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-content-display-children'],
  classNameBindings: ['customDisplayClass'],
  tagName: '',
  enabled: true,

  init() {
    this._super(...arguments);
    let customClass = this.get('customClass');
    let defaultTag = customClass ? 'div' : '';
    this.set('tagName', this.getWithDefault('wrapperTag', defaultTag));
    if (this.get('tagName') === '') {
      // We can't have classNameBindings on tagless view wrappers
      this.set('classNameBindings', []);
    }
  },

  // see https://github.com/emberjs/ember.js/pull/14389
  customDisplayClass: Ember.computed('customClass', {
    get() {
      if (this.get('customClass')) {
        return `${this.get('customClass')}`;
      } else {
        return null;
      }
    }
  }),

  customChildClass: Ember.computed.readOnly('content.customChildClass'),
  childTag: Ember.computed.readOnly('content.childTag'),
  customClass: Ember.computed.readOnly('content.customClass'),
  wrapperTag: Ember.computed.readOnly('content.wrapperTag'),

  propTypes: {
    childTag: PropTypes.oneOf(['li', null]),
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  }
});
