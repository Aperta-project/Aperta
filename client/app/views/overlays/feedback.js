import Ember from 'ember';
import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/feedback',
  layoutName: 'layouts/blank-overlay',
  skipAnimation: false
});
