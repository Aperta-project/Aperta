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

let computed = Ember.computed;

export default Ember.Component.extend({
  classNames: ['progress-spinner'],
  classNameBindings: [
    '_visibleClass',
    '_colorClass',
    '_sizeClass',
    '_alignClass',
    'center:progress-spinner--absolute-center', // change to `absoluteCenter`
  ],

  /**
   *  Toggles visibility
   *
   *  @property visible
   *  @type Boolean
   *  @default false
   **/
  visible: false,

  _visibleClass: computed('visible', 'align', function() {
    if(!this.get('visible')) { return; }

    let modifier = !this.get('align') ? 'inline' : 'block';
    return 'progress-spinner--' + modifier;
  }),

  /**
   *  Color. `green` or `blue` or `white`
   *
   *  @property color
   *  @type String
   *  @default green
   **/
  color: 'green',
  _colorClass: computed.concat('progress-spinner--', 'color'),

  /**
   *  Size. `small` or `large`
   *
   *  @property size
   *  @type String
   *  @default small
   **/
  size: 'small',
  _sizeClass: computed.concat('progress-spinner--', 'size'),

  /**
   *  If true, absolute positioning is used to center vertically and horizontally
   *
   *  @property center
   *  @type boolean
   *  @default false
   **/
  center: false,

  /**
   *  If set, spinner becomes a block level element.
   *  Options are `middle`
   *
   *  @property align
   *  @type String
   *  @default null
   **/
  align: null,
  _alignClass: computed.concat('progress-spinner--', 'align')
});
