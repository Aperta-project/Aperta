import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/billing-card',
  layoutName:   'layouts/overlay',
  cardName: 'billing-card',
  varName: 'PLOS',

  setup: function() {
    this.controller.send("setBillingDetails");
  }.on('didInsertElement')
});
