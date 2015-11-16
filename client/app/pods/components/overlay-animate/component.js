import Ember from 'ember';

export default Ember.Component.extend({
  _animateIn: Ember.on('didInsertElement', function() {
    this.animateIn();
  }),

  animateIn() {
    const method = (this.attrs.type || 'fade') + 'In';

    this[method]().then(()=> {
      const callback = this.attrs.inAnimationComplete;
      if(callback) { callback(); }
    });
  },

  animateOut() {
    const method = (this.get('type') || 'fade') + 'Out';

    this[method]().then(()=> {
      const callback = this.attrs.outAnimationComplete;
      if(callback) { callback(); }
    });
  },

  fadeIn() {
    const element = this.$('.overlay-x');
    const beginProps = { opacity: 0, display: 'block' };
    const animateToProps = { opacity: 1 };

    return $.Velocity.animate(element, animateToProps, {
      duration: 400,
      easing: [250, 20],
      begin: function() { element.css(beginProps); }
    });
  },

  fadeOut() {
    const element = this.$('.overlay-x');
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
