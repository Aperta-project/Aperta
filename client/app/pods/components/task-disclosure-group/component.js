import Ember from 'ember';

export default Ember.Component.extend({
  _teardown: Ember.on('willDestroyElement', function() {
    this.$().off('scroll.' + this.elementId);
  }),

  _setup: Ember.on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      const tasks = this.$().find('.task-disclosure');

      // Note: This element needs to be scrollable!
      this.$().on('scroll.' + this.elementId, function() {
        tasks.each(function() {
          const $task = $(this);
          const amountAboveTop = $task.position().top;
          if(amountAboveTop > 0) {
            $task.find('.task-disclosure-heading').css('top', '');
            return;
          }

          const top = amountAboveTop * -1,
                height = $task.outerHeight(),
                head = $task.find('.task-disclosure-heading'),
                headHeight = head.outerHeight(),
                noRoomForHead = (height + amountAboveTop) < headHeight,
                Y = (noRoomForHead ? top - (top-height) - headHeight : top);

          head.css('top', Y);
        });
      });
    });
  })
});
