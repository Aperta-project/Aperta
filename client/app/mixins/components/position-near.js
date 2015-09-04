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
   *  jquery selector for target to position next to
   *
   *  @property selector
   *  @type String
   *  @default null
   *  @required
  **/
  selector: null,

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
   *  The default will match the width of target component.
   *  This option will override the matchWidth attribute
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
   *  This offset is to prevent the bottom of the select-box-list
   *  from being flush with the bottom of the viewport
   *
   *  @property offsetFromEdge
   *  @type Number
   *  @default 10
   *  @required
  **/
  offsetFromEdge: 10,

  /**
   *  Unique window resize event name for component instance.
   *  Don't use this before the component is in the DOM
   *
   *  @method getResizeEventName
   *  @return {String}
   *  @public
  **/
  getResizeEventName() {
    return 'resize.positionnear-' + this.$().id;
  },

  /**
   *  Do the DOM querying all in one place
   *
   *  @method getPositionDataForTarget
   *  @param {Object} jquery object of target element
   *  @return {Object}
   *  @public
  **/

  getPositionDataForTarget(target) {
    const windowScrollTop  = $(window).scrollTop();
    const windowHeight     = $(window).height();

    const position         = target.position();
    const offset           = target.offset();
    const width            = target.outerWidth();
    const height           = target.outerHeight();
    const positionRelative = target.css('position') === 'relative';

    const heightAbove      = offset.top - windowScrollTop;
    const heightBelow      = windowHeight - heightAbove - height;
    const isCloserToBottom = heightAbove > heightBelow;

    // offset:   coordinates of the element relative to the document
    // position: coordinates of the element relative to the offset parent

    return {
      element: target,
      position: position,
      width: width,
      height: height,
      positionRelative: positionRelative,
      heightAbove: heightAbove,
      heightBelow: heightBelow,
      isCloserToBottom: isCloserToBottom
    };
  },

  /**
   *  @method position
   *  @public
  **/
  position: on('didInsertElement', function() {
    const selector = this.get('selector');
    Ember.assert('position-near requires a selector property', selector);

    Ember.assert('position-near could not find target selector', Ember.$(selector).length);
    const target = this.getPositionDataForTarget(Ember.$(selector));


    // css horizontal

    let height = this.$().height();

    let css = {
      position: 'absolute',
      left: Math.round(target.position.left),
      marginTop: null,
      width: null
    };

    // What is this?
    if(target.positionRelative) {
      css.left = 0;
    }

    // css width

    if(this.get('width')) {
      css.width = this.get('width');
    } else if(this.get('matchWidth')) {
      css.width = target.width;
    }

    // If the positioned element can fit below the target, go there,
    // otherwise, do all the logic below:
    if(height > target.heightBelow) {
      // css height

      if(this.get('setMaxHeight')) {
        const newHeight = target.isCloserToBottom ? target.heightAbove : target.heightBelow;
        if(newHeight < height) {
          css.maxHeight = height = newHeight - this.get('offsetFromEdge');
        }
      }

      // css vertical

      if(target.isCloserToBottom) {
        css.marginTop = -1 * height - target.height;
      }
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
    $(window).on(this.getResizeEventName(), ()=> {
      if(this.get('setMaxHeight')) {
        this.position();
      }
    });
  }),

  _teardownResizeListener: on('willDestroyElement', function() {
    $(window).off(this.getResizeEventName());
  })
});
