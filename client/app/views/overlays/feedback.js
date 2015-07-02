import Ember from 'ember';
import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/feedback',
  layoutName: 'layouts/blank-overlay',
  skipAnimation: false,

  animateIn: function() {
    let options = {
      selector: '#feedback-overlay',
      skipAnimation: this.get('skipAnimation'),
      extraClasses: this.get('controller.overlayClass')
    };

    // TEMP HACK: Remove when on Ember 1.13
    this.get('controller').set('feedbackSubmitted', false);

    Ember.run.scheduleOnce('afterRender', this, this.animateOverlayIn, options);
  }.on('didInsertElement'),
});
