import Ember from 'ember';

/**
 * This component should work exactly like a progress-spinner but can take
 * an optional block which renders a message with the spinner.
 */

export default Ember.Component.extend({
  visible: false,
  color: 'green',
  size: 'small',
  center: false,
  align: null,

  classNames: ['progress-spinner-message']
});
