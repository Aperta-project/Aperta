import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
let { any, bool, func, oneOfType } = PropTypes;

export default Ember.Component.extend({
  propTypes: {
    contentRoot: any.isRequired,
    disabled: bool.isRequired,
    hideCompletedSection: bool,
    owner: any.isRequired,
    preview: bool.isRequired,
    scenario: any.isRequired,
    task: any.isRequired,
    taskStateToggleable: bool.isRequired,
    toggleTaskCompletion: func.isRequired,
    validationErrors: any.isRequired,
    repetition: oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired
  },

  getDefaultProps() {
    return {
      hideCompletedSection: false
    };
  },

  actions: {
    toggleTaskCompletion() {
      this.get('toggleTaskCompletion')();
    }
  }
});
