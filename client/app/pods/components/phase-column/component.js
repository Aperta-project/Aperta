import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['column'],

  phase: null,
  paper: null,

  nextPosition: Ember.computed('phase.position', function() {
    return this.get('phase.position') + 1;
  }),

  commentLooks: null,

  taskSort: ['position'],
  sortedTasks: Ember.computed.sort('phase.tasks.@each.position', 'taskSort'),
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
        // same column re-ordering

        // update is called in 3 cases: single column reordering, after a card leaves a column,
        // and when a card enters a column. we only want to handle the single column reordering
        // in this callback. so we need to detect the other two cases.

        // sender is only set on the receiving column, and only when it was a multi-column
        // drag. we will handle multi-column drags with "remove/receive", so just bail out here.

        // update also fires on both columns during a multi-column drag. we want to ignore the
        // starting column (where senderPhaseId is null) during update (handled during remove), but
        // we need to call updateSortOrder when it is a single-column reorder.

        let receiverPhaseId = ui.item.parent().data('phase-id').toString();
        let singleColumnReorder = (phaseId === receiverPhaseId) && !ui.sender;

        if(singleColumnReorder) {
          self.updateSortOrder(this);
        }
      },

      remove() {
        // leaving one phase
        self.updateSortOrder(this);
      },

      receive(event, ui) {
        // entering a new phase
        let receiverPhaseId = ui.item.parent().data('phase-id') + '';
        let taskId = ui.item.find('.card-content').data('id');
        let updatedOrder = self.calculateTaskPositions(this);
        self.sendAction('changePhaseForTask', taskId, receiverPhaseId, updatedOrder);
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

  calculateTaskPositions(phaseColumn) {
    return $(phaseColumn).find('.card-content').map(function(i,card) {
      return $(card).data('id').toString();
    }).toArray();
  },

  updateSortOrder(phaseColumn) {
    let updatedOrder = this.calculateTaskPositions(phaseColumn);
    this.set('phase.taskPositions', updatedOrder);
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
