import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['column'],

  phase: null,
  paper: null,

  nextPosition: Ember.computed('phase.position', function() {
    return this.get('phase.position') + 1;
  }),

  commentLooks: null,

  noCards: Ember.computed.empty('phase.tasks'),

  setupSortable: Ember.on('didInsertElement', function() {
    let phaseId = this.get('phase.id');
    let self = this;

    this.$('.sortable').sortable({
      items: '.card',
      scroll: false,
      containment: '.columns',
      connectWith: '.sortable',

      update(event, ui) {
        let senderPhaseId   = phaseId;
        let receiverPhaseId = ui.item.parent().data('phase-id') + '';
        let task            = self.getTaskByID(ui.item.find('.card-content').data('id'));

        if(senderPhaseId !== receiverPhaseId) {
          self.sendAction('changePhaseForTask', task, receiverPhaseId);
          Ember.run.scheduleOnce('afterRender', self, function() {
            ui.item.remove();
          });
        }

        let updatedOrder = $(this).find('.card-content').map(function(i,card) {
          return $(card).data('id');
        }).toArray();

        self.updateSortOrder(updatedOrder);
      },

      start(event, ui) {
        $(ui.item).addClass('card--dragging');
        // class added to set overflow: visible;
        $(ui.item).closest('.column-content').addClass('column-content--dragging');
      },

      stop(event, ui) {
        $(ui.item).removeClass('card--dragging');
        $(ui.item).closest('.column-content').removeClass('column-content--dragging');
      }
    });
  }),

  updateSortOrder(updatedOrder) {
    this.set('phase.task_positions', updatedOrder);
    this.get('phase').save();
  },

  getTaskByID(taskId) {
    return this.get('phase.tasks').find(function(t) {
      return t.get('id') === taskId.toString();
    });
  },

  actions: {
    chooseNewCardTypeOverlay(phase) { this.sendAction('chooseNewCardTypeOverlay', phase); },
    viewCard(task, queryParams) { this.sendAction('viewCard', task, queryParams); },
    savePhase(phase)            { this.sendAction('savePhase', phase); },
    addPhase(position)          { this.sendAction('addPhase', position); },
    removePhase(phase)          { this.sendAction('removePhase', phase); },
    rollbackPhase(phase)        { this.sendAction('rollbackPhase', phase); },
    showDeleteConfirm(task)     { this.sendAction('showDeleteConfirm', task); }
  }
});
