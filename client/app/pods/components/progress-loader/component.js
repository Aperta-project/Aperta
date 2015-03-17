import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['loader-component-circle'],
  classNameBindings: [
    'visible:loader-component-circle--visible', 
    'blue:blue', 
    'white:white', 
    'large:large'
  ]
})
