import Ember from 'ember';
const { on } = Ember;

export default Ember.Mixin.create({
  matchWidth: true,
  setMaxHeight: false,
  width: null,
  animationClass: null,

  // attrs:
  selector: null,

  position: on('didInsertElement', function() {
    let selector = this.get('selector');
    if(Ember.isEmpty(selector)) { return; }

    let target = Ember.$(selector);
    Ember.assert('position-near could not find target selector', target.length);

    let position = target.position();
    let offset   = target.offset();
    let targetHeight = target.outerHeight();

    let css = {
      position: 'absolute',
      top: position.top + targetHeight,
      left: position.left
    };

    if(this.get('matchWidth')) {
      css.width = target.outerWidth();
    }

    if(this.get('setMaxHeight')) {
      css.maxHeight = $(window).height() - offset.top - targetHeight - 10;
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
