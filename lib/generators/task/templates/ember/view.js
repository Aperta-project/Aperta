ETahi.<%= class_name %>OverlayView = ETahi.OverlayView.extend({
  templateName: "<%= engine_file_name %>/overlays/<%= file_name %>_overlay",
  layoutName: "layouts/overlay_layout",

  setup: function() {
  }.on('didInsertElement')
});
