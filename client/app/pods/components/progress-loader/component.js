import Ember from 'ember';
/**
 *   ## How to Use
 *
 *   In your template:
 *
 *   ```
 *    {{progress-loader visible=someBoolean}}
 *   ```
 *
 *   In your controller or component toggle the boolean:
 *
 *   ```
 *    this.set('someBoolean', true);
 *   ```
 **/

export default Ember.Component.extend({
  classNames: ['loader-component-circle'],
  classNameBindings: [
    'visible:loader-component-circle--visible', 
    'blue:blue', 
    'white:white', 
    'large:large'
  ]
});
