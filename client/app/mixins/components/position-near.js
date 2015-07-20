import Ember from 'ember';

export default Ember.Mixin.create({
  matchWidth: true,
  setMaxHeight: false,
  width: null,
  animationClass: null,

  // attrs:
  selector: null,

  position: Ember.on('didInsertElement', function() {
    let selector = this.get('selector');
    if(Ember.isEmpty(selector)) { return; }

    let target = Ember.$(selector);
    let offset = target.offset();
    let targetHeight = target.outerHeight();

    let css = {
      position: 'absolute',
      top: offset.top + targetHeight,
      left: offset.left
    };

    if(this.get('matchWidth')) {
      css.width = target.outerWidth();
    }

    if(this.get('setMaxHeight')) {
      css.height = $(window).height() - offset.top - targetHeight - 10;
    }

    this.$().css(css);
  }),

  _setupResizeListener: Ember.on('didInsertElement', function() {
    $(window).on('resize.positionnear', ()=> {
      this.position();
    });
  }),

  _teardownResizeListener: Ember.on('willDestroyElement', function() {
    $(window).off('resize.positionnear');
  })
});
