import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/<%= dasherizedModuleName %>',
  layoutName:   'layouts/overlay',
  cardName: '<%= dasherizedModuleName %>'
});
