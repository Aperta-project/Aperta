import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../../../helpers/custom-assertions';

moduleForComponent(
  'figure-task',
  'Integration | Components | Tasks | figure thumbnail', {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      manualSetup(this.container);
    }
  }
);

let template = hbs`{{figure-thumbnail isEditable=true figure=figure destroyFigure=(action destroyFigure)}}`;

test('it renders stuff when status is done', function(assert) {
  this.set('destroyFigure', function(){});
  this.set('figure', make('figure', {status: 'done', title: 'My Title'}));
  this.render(template);

  assert.textPresent('.title', 'My Title', 'renders the title');
});

test('it renders a progress message while processing', function(assert) {
  this.set('destroyFigure', function(){});
  this.set('figure', make('figure', {status: 'processing'}));
  this.render(template);
  assert.elementFound('.progress-text', 'shows the progress message');
});

test('it renders an error state', function(assert) {
  let done = assert.async();
  assert.expect(2);

  this.set('figure', make('figure', {status: 'error'}));
  this.set('destroyFigure', function() {
    assert.ok(true, 'destroyFigure action is invoked');
    done();
  });

  this.render(template);
  assert.elementFound('.progress-error', 'shows an error message');

  this.$('.upload-cancel-button').click();
});

test('it allows the user to cancel', function(assert) {
  this.set('destroyFigure', function(){});
  this.set('figure', make('figure', {status: 'processing'}));
  this.render(template);

  this.$('.upload-cancel-link').click();

  assert.textPresent('.progress-text','Upload canceled. Re-upload to try again', 'shows cancel message');
});

test('it sets figure title to \'Fig [rank]\' on input', function(assert) {
  let newRank = 5;
  this.set('destroyFigure', function(){});
  this.set('figure', make('figure', {status: 'done', title: 'Fig 2'}));
  this.render(template);
  this.$('.fa-pencil').click();
  this.$('input[type=number]').val(newRank).trigger('input');
  assert.equal(this.get('figure.title'), 'Fig ' + newRank);
});
