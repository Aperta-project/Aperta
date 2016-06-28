import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../../../helpers/custom-assertions';
import Factory from '../../../helpers/factory'

let createTaskWithFigures = function(figures) {
  return make('figure-task', {
    paper: {
      figures: figures
    },
    nestedQuestions: [
      {id: 1, ident: "figures--complies"}
    ]
  });
}

moduleForComponent(
  'figure-task',
  'Integration | Components | Tasks | Figure', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    Factory.createPermission('figureTask', 1, ['edit', 'view']);
  }
});

let template = hbs`{{figure-task task=testTask}}`;
let errorSelector = '.figure-thumbnail .error-message:not(.error-message--hidden)'
test('it renders the paper\'s figures', function(assert) {
  let testTask = createTaskWithFigures([{rank: 1, title: 'Fig. 1', id: 1}]);
  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound('.figure-thumbnail', 1);

});

test('it shows an error message for figures with the same rank', function(assert) {
  let testTask = createTaskWithFigures([{rank: 1, title: 'Some Title', id: 1},
                                        {rank: 1, title: 'Another Title', id: 2}]);
  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound(errorSelector, 2);
});

test('it shows an error message for a non-numeric label', function(assert) {
  let testTask = createTaskWithFigures([{rank: 0, title: 'Some Title', id: 1}]);
  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound(errorSelector, 1);
});

test('it orders the figures based on rank', function(assert) {
  let testTask = createTaskWithFigures([{rank: 2, title: 'Title Two', id: 2},
                                        {rank: 0, title: 'Unlabeled', id: 3},
                                        {rank: 1, title: 'Title One', id: 1}]);
  this.set('testTask', testTask);
  this.render(template);
  let ids = this.$('.figure-thumbnail').map((_i, el) => $(el).data('figure-id')).get();
  assert.deepEqual(ids, [1, 2, 3], 'Figures are sorted with rank 0 coming last');
});
