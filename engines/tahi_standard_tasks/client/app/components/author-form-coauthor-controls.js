import Ember from 'ember';
import PropTypeMixin, {PropTypes} from 'ember-prop-types'

const {
  Component
} = Ember;

export default Component.extend(PropTypes, {
  
  author: PropTypes.EmberObject,
  disabled: PropTypes.bool,

  actions: {
    setConfirmation(status) {
      this.attrs.setConfirmation(status);
    }
  }

  
})
