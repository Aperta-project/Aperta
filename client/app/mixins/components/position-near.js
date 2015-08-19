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
   *  @method position
   *  @public
  **/
  position: on('didInsertElement', function() {
    let selector = this.get('selector');
    Ember.assert('position-near requires a selector property', selector);

    let target = Ember.$(selector);
    Ember.assert('position-near could not find target selector', target.length);

    let position = target.position();
    let windowScrollTop = $(window).scrollTop();
    let offset   = target.offset();
    let targetHeight = target.outerHeight();
    let windowHeight = $(window).height();

    let heightTop       = offset.top - windowScrollTop;
    let heightBottom    = windowHeight - heightTop;
    let closerToBottom  = heightTop > heightBottom;
    // css left

    let css = {
      position: 'absolute',
      left: Math.round(position.left)
    };

    // css vertical

    if(closerToBottom) {
      css.marginTop = -1 * this.$().height() - targetHeight;
    }

    // css width

    if(this.get('width')) {
      css.width = this.get('width');
    } else if(this.get('matchWidth')) {
      css.width = target.outerWidth();
    }

    // css maxHeight

    if(this.get('setMaxHeight')) {
      let height = closerToBottom ? heightTop : heightBottom;
      css.maxHeight = height - this.get('offsetFromEdge');
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
