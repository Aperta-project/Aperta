import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/feedback',
  layoutName: 'layouts/blank-overlay',

  animateIn: function() {
    Ember.run.scheduleOnce('afterRender', this, this.animateOverlayIn, '#feedback-overlay');
  }.on('didInsertElement'),
});
