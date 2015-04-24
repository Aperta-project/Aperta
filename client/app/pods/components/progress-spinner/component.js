import Ember from 'ember';
/**
 *   ## How to Use
 *
 *   In your template:
 *
 *   ```
 *    {{progress-spinner visible=someBoolean color="green" size="small"}}
 *   ```
 *
 *   In your controller or component toggle the boolean:
 *
 *   ```
 *    this.set('someBoolean', true);
 *   ```
 **/

export default Ember.Component.extend({
  classNames: ['progress-spinner'],
  classNameBindings: [
    'visible',
    'color',
    'size',
    'center'
  ],

  /**
   *  Toggles visibility
   *
   *  @property visible
   *  @type Boolean
   *  @default false
   **/
  visible: false,

  /**
   *  Color. `green` or `blue` or `white`
   *
   *  @property color
   *  @type String
   *  @default green
   **/
  color: 'green',

  /**
   *  Size. `small` or `large`
   *
   *  @property size
   *  @type String
   *  @default small
   **/
  size: 'small',

  /**
   *  Center. true or false. Uses absolute positioning
   *
   *  @property center
   *  @type boolean
   *  @default false
   **/
  center: false
});
