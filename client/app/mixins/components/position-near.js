import Ember from 'ember';

const { on } = Ember;

/**
 *  position-near is a mixin for components to position
 *  them near other DOM nodes
 *
 *  @extends Ember.Mixin
 *  @since 1.3.0
**/

export default Ember.Mixin.create({
  // -- attrs:

  /**
   *  jquery selector for target to postion next to
   *
   *  @property selector
   *  @type String
   *  @default null
   *  @required
  **/
  selector: null,

  /**
   *  The default is to position directly below the target,
   *  this option will put it directly over
   *
   *  @property positionOver
   *  @type Boolean
   *  @default false
   *  @optional
  **/
  positionOver: false,

  /**
   *  This option will decrease the css max-height property to prevent
   *  the list from flowing out of the viewport. A class will need to
   *  be assigned to the component mixining this position-near. The class
   *  will need `overflow: auto` to be set (see example). This mixin
   *
   *  @example
   *    {{#my-component selector="#some-node"
   *                    setMaxHeight=true
   *                    class="my-component"}}
   *
   *    .my-component { overflow: auto; }
   *
   *  @property setMaxHeight
   *  @type Boolean
   *  @default false
   *  @optional
  **/
  setMaxHeight: false,

  /**
   *  The default is match the width of target component.
   *  this option will override the matchWidth attribute
   *
   *  @property width
   *  @type String
   *  @default null
   *  @optional
  **/
  width: null,

  /**
   *  Match the width of target component
   *
   *  @property matchWidth
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  matchWidth: true,

  /**
   *  @method position
   *  @public
  **/
  position: on('didInsertElement', function() {
    let selector = this.get('selector');
    Ember.assert('position-near requires a selector property', selector);

    let target = Ember.$(selector);
    Ember.assert('position-near could not find target selector', target.length);

    let position = target.position();
    let offset   = target.offset();
    let targetHeight = target.outerHeight();
    let windowHeight = $(window).height();

    // css left

    let css = {
      position: 'absolute',
      left: Math.round(position.left)
    };

    // css top

    if(this.get('positionOver')) {
      css.top = Math.round(position.top);
    } else {
      css.top = Math.round(position.top) + targetHeight;
    }

    // css width

    if(this.get('width')) {
      css.width = this.get('width');
    } else if(this.get('matchWidth')) {
      css.width = target.outerWidth();
    }

    // css maxHeight

    if(this.get('setMaxHeight')) {
      let height = windowHeight - offset.top - targetHeight - 10;

      if(height < targetHeight) {
        height = targetHeight;
      }

      css.maxHeight = height;
    }

    this.$().css(css);
  }),

  /**
   *  Start listening for window resize events.
   *  If `setMaxHeight` is true we may need to adjust height.
   *
   *  @method _setupResizeListener
   *  @private
  **/
  _setupResizeListener: on('didInsertElement', function() {
    let eventName = 'resize.positionnear-' + this.$().id;
    $(window).on(eventName, ()=> {
      if(this.get('setMaxHeight')) {
        this.position();
      }
    });
  }),

  _teardownResizeListener: on('willDestroyElement', function() {
    let eventName = 'resize.positionnear-' + this.$().id;
    $(window).off(eventName);
  })
});
