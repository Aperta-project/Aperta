import Ember from 'ember';
import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/feedback',
  layoutName: 'layouts/blank-overlay',
  instant: false,

  animateIn: function() {
    let options = {
      selector: '#feedback-overlay',
      instant: this.get('instant'),
      extraClasses: this.get('controller.overlayClass')
    };

    Ember.run.scheduleOnce('afterRender', this, this.animateOverlayIn, options);
  }.on('didInsertElement'),
});
