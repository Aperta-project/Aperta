import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['expanding-textarea'],
  textareaClassNames: null,
  placeholder: null,
  value: null,

  _setupGrowingTextarea: Ember.on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      // $textarea: the textarea to auto-expand and turn on resizing for
      // $resizeArrow: container that contains the two diagonal lines
      // $line1: the longer, inner resize line
      // $line2: the shorter, outer resize line
      var $textarea = this.$('textarea'),
        $resizeArrow = this.$('.expanding-textarea-arrow'),
        $line1 = this.$('.expanding-textarea-arrow-line1', $resizeArrow),
        $line2 = this.$('.expanding-textarea-arrow-line2', $resizeArrow);

      // Use the initial height of the textarea as the minimum height.
      // We will not let the user resize the textarea smaller than this.
      var minOuterHeight = $textarea.outerHeight(),
        minHeight = $textarea.height();

      var resizeTextarea = () => {
        if(!this.get('user-resized')){
          $textarea.height(0);
          $textarea.scrollTop(0);
          let height = ($textarea[0].scrollHeight + 1) - $textarea[0].clientHeight;
          $textarea.height(Math.max(minHeight, height));
        }
      };

      // When a user types into the textarea auto-resize the height unless
      // they have manually starting resizing it. Once they do that they
      // are in control of the textarea's height.
      $textarea.on('input', () => {
        resizeTextarea();
      }).trigger('input');


      // Apply CSS styles inside the component so there are no external
      // dependencies
      $resizeArrow.css({
        'cursor': 'row-resize',
        'position': 'relative'
      });

      $line1.css({
      	'float': 'right',
      	'position': 'absolute',
      	'right': '6px',
      	'bottom': '8px',
        'height': '7px',
        'width': '7px',
        'border-right': '1px solid gray',
        '-moz-transform': 'skew(-45deg)',
        '-webkit-transform': 'skew(-45deg)',
        'transform': 'skew(-45deg)'
      });

      $line2.css({
      	'float': 'right',
      	'position': 'absolute',
      	'right': '4px',
      	'bottom': '8px',
        'height': '3px',
        'width': '3px',
        'border-right': '1px solid gray',
        '-moz-transform': 'skew(-45deg)',
        '-webkit-transform': 'skew(-45deg)',
        'transform': 'skew(-45deg)'
      });

      var $document = $(document);

      // newHeight: contains the new height of the textarea based on the
      //            current dragging of the user
      var newHeight;

      $resizeArrow.on('mousedown', (e) => {
        e.preventDefault();

        this.set('user-resized', true);

        $document.on('mousemove', function(e) {
          e.preventDefault();
          newHeight = e.screenY - $textarea.offset().top - minOuterHeight;

          // Ensure that the user cannot make the textarea smaller than
          // the minOuterHeight
          if(newHeight >= minOuterHeight){
            $textarea.css('height', newHeight);
          }
        });
      });

      $document.on('mouseup', function(e) {
        e.preventDefault();
        $document.off('mousemove');
      });
    });
  }),

  _teardownGrowingTextarea: Ember.on('willDestroyElement', function() {
    let $textarea = this.$('textarea'),
      $resizeArrow = this.$('.expanding-textarea-arrow');
    $resizeArrow.off();
    $textarea.off();
  })
});
