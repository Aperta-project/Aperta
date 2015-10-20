import ModalDialog from 'ember-modal-dialog/components/modal-dialog';

export default ModalDialog.extend({
  overlayClassNames: "overlay overlay--fullscreen",
  containerClassNames: "overlay-container",
  targetAttachment: "none"
});
