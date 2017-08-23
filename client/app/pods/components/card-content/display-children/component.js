import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  tagName: '',

  init() {
    let customClass = this.get('customClass');
    if (customClass) {
      this.set('classNames', [customClass]);
    }
    this.set('tagName', this.get('wrapperTag'));
    this._super(...arguments);
  },

  customChildClass: Ember.computed.readOnly('content.customChildClass'),
  childTag: Ember.computed.readOnly('content.childTag'),
  customClass: Ember.computed.readOnly('content.customClass'),
  wrapperTag: Ember.computed.readOnly('content.wrapperTag'),

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  }
});
