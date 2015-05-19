import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['column'],

  phase: null,
  paper: null,

  nextPosition: function() {
    return this.get('phase.position') + 1;
  }.property('phase.position'),

  commentLooks: null,

  sortedTasks: function() {
    return this.get('phase.tasks').sortBy('position');
  }.property('phase.tasks.[]'),

  noCards: Ember.computed.empty('sortedTasks'),

  setupSortable: function() {
    let phaseId = this.get('phase.id');
    let self = this;

    this.$('.sortable').sortable({
      items: '.card',
      scroll: false,
      containment: '.columns',
      connectWith: '.sortable',

      update(event, ui) {
        let updatedOrder    = {};
        let senderPhaseId   = phaseId;
        let receiverPhaseId = ui.item.parent().data('phase-id') + '';
        let task            = self.getTaskByID(ui.item.find('.card-content').data('id'));

        if(senderPhaseId !== receiverPhaseId) {
          self.sendAction('changePhaseForTask', task, receiverPhaseId);
          Ember.run.scheduleOnce('afterRender', self, function() {
            ui.item.remove();
          });
        }

        $(this).find('.card-content').each(function(index) {
          updatedOrder[$(this).data('id')] = index + 1;
        });

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
  }.on('didInsertElement'),

  updateSortOrder(updatedOrder) {
    this.beginPropertyChanges();
    this.get('phase.tasks').forEach(function(task) {
      task.set('position', updatedOrder[task.get('id')]);
    });
    this.endPropertyChanges();
    this.get('phase.tasks').invoke('save');
  },

  getTaskByID(taskId) {
    return this.get('phase.tasks').find(function(t) {
      return t.get('id') === taskId.toString();
    });
  },

  actions: {
    chooseNewCardTypeOverlay(phase) { this.sendAction('chooseNewCardTypeOverlay', phase); },
    viewCard(task, queryParams) { this.sendAction('viewCard', task, queryParams); },
    savePhase(phase)   { this.sendAction('savePhase', phase); },
    addPhase(position) { this.sendAction('addPhase', position); },
    removePhase(phase) { this.sendAction('removePhase', phase); },
    showDeleteConfirm(task) { this.sendAction('showDeleteConfirm', task); }
  }
});
