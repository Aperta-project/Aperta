import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'button',
  size: 'small',
  color: 'blue',
  attributeBindings: ['disabled'],
  disabled: true,
  spinnerSize: 'small'
});
