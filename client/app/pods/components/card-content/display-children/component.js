import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-content-display-children'],
  tagName: '',

  init() {
    this._super(...arguments);
    let customClass = this.get('customClass');
    if (customClass) {
      let classNames = this.get('classNames');
      classNames.push(customClass);
      this.set('classNames', classNames);
    }
    let defaultTag = customClass ? 'div' : '';
    this.set('tagName', this.getWithDefault('wrapperTag', defaultTag));
  },

  customChildClass: Ember.computed.readOnly('content.customChildClass'),
  childTag: Ember.computed.readOnly('content.childTag'),
  customClass: Ember.computed.readOnly('content.customClass'),
  wrapperTag: Ember.computed.readOnly('content.wrapperTag'),

  propTypes: {
    childTag: PropTypes.oneOf(['li', null]),
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  }
});
