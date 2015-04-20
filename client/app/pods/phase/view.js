import Ember from 'ember';

export default Ember.View.extend({
  classNames: ['column'],

  nextPosition: function() {
    return this.get('controller.model.position') + 1;
  }.property('controller.model.position'),

  setupSortable: function() {
    let controller = this.get('controller');
    let phaseId    = this.get('controller.model.id');

    this.$('.sortable').sortable({
      items: '.card',
      scroll: false,
      containment: '.columns',
      connectWith: '.sortable',
      update: function(event, ui) {
        let updatedOrder    = {};
        let senderPhaseId   = phaseId;
        let receiverPhaseId = ui.item.parent().data('phase-id') + '';

        if(senderPhaseId !== receiverPhaseId) {
          controller.send('changePhaseForTask', ui.item.find('.card-content').data('id'), receiverPhaseId);
          Ember.run.scheduleOnce('afterRender', this, function() {
            ui.item.remove();
          });
        }

        $(this).find('.card-content').each(function(index) {
          updatedOrder[$(this).data('id')] = index + 1;
        });

        controller.send('updateSortOrder', updatedOrder);
      },
      start: function(event, ui) {
        $(ui.item).addClass('card--dragging');
        // class added to set overflow: visible;
        $(ui.item).closest('.column-content').addClass('column-content--dragging');
      },
      stop: function(event, ui) {
        $(ui.item).removeClass('card--dragging');
        $(ui.item).closest('.column-content').removeClass('column-content--dragging');
      }
    });
  }.on('didInsertElement')
});
