import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/supporting-information',
  layoutName: 'layouts/overlay',

  setupTooltip: function() {
    this.$().find('.file-original-download-link').tooltip();
  }.on('didInsertElement')
});
