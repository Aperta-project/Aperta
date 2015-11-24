import Ember from 'ember';

/**
 *  OverlayComponentBase wraps up two other
 *  components (ember-wormhole and overlay-animate) and handles
 *  when an overlay is shown or hidden.
 *
 *  ## How it works
 *
 *  `ember-wormhole` renders the overlay at the root of the DOM tree
 *
 *  `overlay-animate` handles animations
 *
 *  `overlay-base` yields the method to trigger the out animation
 *
 *  Basic working example:
 *  @example
 *    {{#overlay-base visible=showStuff
 *                    outAnimationComplete=(action "hideStuff")
 *                    as |animateOut|}}
 *        <Overlay close=(action animateOut)>
 *    {{/overlay-base}}
 *
 *  @class OverlayBaseComponent
 *  @extends Ember.Component
 *  @since 1.3.5+
**/

export default Ember.Component.extend({
  /**
   *  ID of DOM element overlay will be rendered in
   *  This attribute is passed to `ember-wormhole`
   *
   *  @property to
   *  @type String
   *  @default 'overlay-drop-zone'
   *  @required
  **/
  to: 'overlay-drop-zone',

  /**
   *  Toggle insertion of overlay into DOM
   *
   *  @property visible
   *  @type Boolean
   *  @default false
   *  @required
  **/
  visible: false,

  /**
   *  Method called after out animation is complete.
   *  This property should be set to an action.
   *  This method is passed to `overlay-animate`
   *
   *  @method outAnimationComplete
   *  @type Function
   *  @required
  **/
  outAnimationComplete: null,

  init() {
    this._super(...arguments);
    Ember.assert(
      'You must provide an outAnimationComplete action to OverlayBaseComponent',
      !Ember.isEmpty(this.get('outAnimationComplete'))
    );
  }
});
