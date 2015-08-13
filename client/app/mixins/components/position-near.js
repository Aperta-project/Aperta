import Ember from 'ember';
const { on } = Ember;

export default Ember.Mixin.create({
  matchWidth: true,
  setMaxHeight: false,
  width: null,
  animationClass: null,
  positionOver: false,

  // attrs:
  selector: null,

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

  _setupResizeListener: on('didInsertElement', function() {
    $(window).on('resize.positionnear', ()=> {
      this.position();
    });
  }),

  _teardownResizeListener: on('willDestroyElement', function() {
    $(window).off('resize.positionnear');
  })
});
