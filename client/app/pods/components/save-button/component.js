import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'button',
  text: '',
  displayProgressBar: false,
  size: 'small',
  color: 'blue',
  attributeBindings: ['disabled'],
  disabled: true,
  spinnerSize: 'small',
  align: 'center'
});
