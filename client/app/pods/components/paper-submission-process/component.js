import Ember from 'ember';

const forceRepaint = function forceRepaint() {
  const body = $('body').get(0);
  body.style.display='none';
  body.offsetHeight;
  body.style.display='';
};

export default Ember.Component.extend({
  classNameBindings: [':paper-submission-process', 'showProcess'],
  showProcess: false,

  _toggle: Ember.observer('showProcess', function() {
    const banner = this.$('#submission-process');
    const paper  = this.$('#paper-container');
    const currentTop = paper.css('top');
    let futureTop = 60;

    if(this.get('showProcess')) {
      futureTop = banner.offset().top + banner.outerHeight();
    }

    const beginProps = { top: currentTop };
    const animateToProps = { top: futureTop };

    return $.Velocity.animate(paper, animateToProps, {
      duration: 300,
      begin: function() { paper.css(beginProps); },
    }).then(function() {
      // Chrome animation fix.
      // Forces flexbox columns to recalc their height?
      forceRepaint();
    });
  }),

  _pageLoad: Ember.on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      this._toggle();
    });
  }),

  renderEngagementBanner: Ember.computed(
    'paper.{gradualEngagement,isWithdrawn}',
    function() {
      return this.get('paper.gradualEngagement') &&
        !this.get('paper.isWithdrawn');
    }
  ),

  actions: {
    toggle() {
      this.attrs.toggle();
    }
  }
});
