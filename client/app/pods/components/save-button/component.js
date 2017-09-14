import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  tagName: 'button',
  attributeBindings: ['disabled'],

  propTypes: {
    displaySpinner: PropTypes.bool.isRequired,
    spinnerSize: PropTypes.string,
    color: PropTypes.string,
    disabled: PropTypes.bool.isRequired,
    align: PropTypes.string
  },
  
  getDefaultProps() {
    return {
      displaySpinner: false,
      color: 'blue',
      disabled: true,
      spinnerSize: 'small',
      align: 'center'
    };
  }
});
