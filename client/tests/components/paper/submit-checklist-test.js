import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import registerCustomAssertions from '../../helpers/custom-assertions';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';

moduleForComponent(
  'component:paper/paper-submit',
  'Integration | Component | paper submit checklist',
  { integration: true,
    beforeEach() {

      initTruthHelpers();
    }
  }
);

let template = hbs`{{paper-submit/checklist completedStage=completedStage}}`

test('it renders stage numbers from completedStage', function(assert) {
  this.set('completedStage', 2);
  this.render(template);
  assert.elementsFound(
    '.fa-check',
    2,
    'renders a check for each complete stage'
  );
  assert.textPresent(
    '.ball.img-circle',
    '3',
    'shows a number for the uncompleted stage'
  );
  this.set('completedStage', 0);
  assert.elementsFound('.fa-check', 0, 'no checks found');
  assert.textPresent('.ball.img-circle', '123', 'all numbers rendered');

});

test('it adds the bright class from completedStage', function(assert) {
  this.set('completedStage', 2);
  this.render(template);
  assert.elementsFound('.bright', 2)
});

