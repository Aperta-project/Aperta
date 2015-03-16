import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['spinner-component-circle'],
  classNameBindings: [
    'visible:spinner-component-circle--visible', 
    'blue:blue', 
    'green:green', 
    'white:white', 
    'small:small', 
    'large:large'
  ]
})
