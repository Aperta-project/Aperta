import Ember from 'ember';

/**
 *  This component handles the in and out animations for overlays.
 *  Supports different ways to animate in, defaults to fade.
 *
 *  ## How it works
 *
 *  Uses Velocity.js for animations.
 *
 *  Under normal usage overlay-animate would be expected to have a parent
 *  toggling whether or not `overlay-animate` is in the DOM. After the
 *  out animation is complete, the action passed to `outAnimationComplete`
 *  would be expected to do this toggling. See examples.
 *
 *  Basic working example:
 *  @example
 *    {{#if showStuff}}
 *      {{#overlay-animate outAnimationComplete=(action "hideStuff")
 *                         as |animateOut|}}
 *        <Overlay close=(action animateOut)>
 *      {{/overlay-animate}}
 *    {{/if}}
 *
 *  Example with all attributes:
 *  @example
 *    {{#if showStuff}}
 *      {{#overlay-animate inAnimationComplete=(action "doSomething")
 *                         outAnimationComplete=(action "hideStuff")
 *                         as |animateOut|}}
 *        <Overlay close=(action animateOut)>
 *      {{/overlay-animate}}
 *    {{/if}}
 *
 *  Possible parent implementation:
 *
 *  Ember.Component.extend({
 *    showStuff: false,
 *    actions {
 *      showStuff() { this.set('showStuff', true); },
 *      hideStuff() { this.set('showStuff', false); },
 *      doSomething() {
 *        // overlay finished animating in,
 *        // disable polling, etc.
 *      }
 *    }
 *  });
 *
 *  @class OverlayAnimateComponent
 *  @extends Ember.Component
 *  @since 1.3.5+
**/

export default Ember.Component.extend({
  /**
   *  Base name for in and out animations.
   *  A type of `fade` will use the `fadeIn` and `fadeOut` methods
   *
   *  @property type
   *  @type String
   *  @default 'fade'
   *  @required
  **/
  type: 'fade',

  /**
   *  Method called after in animation is complete.
   *  Expected use case is this property to be an action
   *
   *  @method inAnimationComplete
   *  @optional
  **/
  inAnimationComplete(){},

  /**
   *  Method called after out animation is complete.
   *  This property should be set to an action.
   *
   *  @method outAnimationComplete
   *  @required
  **/
  outAnimationComplete: null,

  init() {
    this._super(...arguments);
    this._checkForAnimationMethods();
    this._checkForOutAnimationCallback();
  },

  _checkForOutAnimationCallback() {
    Ember.assert(
      'OverlayAnimate requires an `outAnimationComplete` method',
      !Ember.isEmpty(this.get('outAnimationComplete'))
    );
  },

  _checkForAnimationMethods() {
    const inAnim  = this.get('type') + 'In';
    const outAnim = this.get('type') + 'Out';

    Ember.assert(
      'OverlayAnimate does not have the ' + inAnim + ' method',
      !Ember.isEmpty(this[inAnim])
    );

    Ember.assert(
      'OverlayAnimate does not have the ' + outAnim + ' method',
      !Ember.isEmpty(this[outAnim])
    );
  },

  _animateIn: Ember.on('didInsertElement', function() {
    this.animateIn();
  }),

  animateIn() {
    const method = this.get('type') + 'In';

    this[method]().then(()=> {
      if (!this.get('isDestroyed')) {
        this.get('inAnimationComplete')();
      }
    });
  },

  animateOut() {
    const method = this.get('type') + 'Out';

    this[method]().then(()=> {
      if (!this.get('isDestroyed')) {
        this.get('outAnimationComplete')();
      }
    });
  },

  fadeIn() {
    const element = this.$('.overlay');
    const beginProps = { opacity: 0, display: 'block' };
    const animateToProps = { opacity: 1 };

    return $.Velocity.animate(element, animateToProps, {
      duration: 400,
      easing: [250, 20],
      begin: function() { element.css(beginProps); }
    });
  },

  fadeOut() {
    const element = this.$('.overlay');
    const animateToProps = { opacity: 0 };

    return $.Velocity.animate(element, animateToProps, {
      duration: 400,
      easing: [250, 20]
    });
  },

  actions: {
    animateOut() { this.animateOut(); }
  }
});
