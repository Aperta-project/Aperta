import Ember from 'ember';

export default Ember.Component.extend({
  _setupGrowingTextarea: Ember.on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      var $textarea = this.$('textarea');

      $textarea.on('input', function() {
        this.style.height = this.scrollHeight + 'px';
      }).trigger('input');


      // Only keep the resize bar if the browser is IE.
      var ua = window.navigator.userAgent;
      var msie = ua.indexOf('MSIE ');
      var trident = ua.indexOf('Trident/');
      var edge = ua.indexOf('Edge/');

      var $dragToResize = this.$('div.drag-to-resize');
      if (msie > 0 || trident > 0 || edge > 0) {
        var $document = $(document);
        var dragOffset = $dragToResize.data('drag-offset');
        $dragToResize.on('mousedown', function(e) {
          e.preventDefault();

          $document.on('mousemove', function(e) {
            e.preventDefault();
            $textarea.css('height', e.screenY - $textarea.offset().top - dragOffset);
          });
        });

        $document.on('mouseup', function(e) {
          e.preventDefault();
          $document.off('mousemove');
        });
      } else {
        $dragToResize.remove();
      }
    });
  }),

  _teardownGrowingTextarea: Ember.on('willDestroyElement', function() {
    this.$('textarea').off();
  })
});
