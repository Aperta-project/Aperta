import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from '../helpers/custom-assertions';

moduleForComponent(
  'paper-submission-process',
  'Integration | Component | paper submission', {
  integration: true,

  beforeEach() {
    // initTruthHelpers();
    customAssertions();
  }
});

test('Showing the gradual engagement banner', function(assert) {
  let template = hbs`
  {{#paper-submission-process
    showProcess=false
    paper=paper
    toggle=(action stubAction)}}

    Hello
  {{/paper-submission-process}}`;

  let paper = Ember.Object.create({gradualEngagement: true,
                                  isWithdrawn: false});
  this.set('paper', paper);

  this.set('stubAction', function() {});

  this.render(template);
  assert.elementFound(
    '#submission-process',
    `the submission process partial is rendered when
    the paper is gradual engagement and not withdrawn`
  );

  Ember.run(() => paper.setProperties({gradualEngagement: true,
                                      isWithdrawn: true}));

  assert.elementNotFound(
    '#submission-process',
    `the submission process partial is not rendered when
    the paper has been withdrawn`
  );

  Ember.run(() => paper.setProperties({gradualEngagement: false,
                                      isWithdrawn: false}));

  assert.elementNotFound(
    '#submission-process',
    `the submission process partial is not rendered when
    the paper isn't gradual engagement`
  );

});
