import {
  moduleForComponent,
  test
} from 'ember-qunit';

import FactoryGuy from 'ember-data-factory-guy';
import {
  manualSetup
} from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('review-status', 'Integration | Component | Scheduled Event Status', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    let dueDate = moment('2020-08-19', 'YYYY-MM-DD');
    this.set('dueDate', dueDate);
  }
});

test('renders inactive toggle when event is passive', function(assert) {
  let scheduledEvent = FactoryGuy.make('scheduled-event', {
    name: 'Pre Event',
    dispatchAt: moment(this.get('dueDate')).add(2, 'days'),
    state: 'passive'
  });
  this.set('event', scheduledEvent);
  this.render(hbs `{{scheduled-event-status event=event}}`);
  assert.textPresent('.scheduled-event p', '2 days after due date');
});

test('renders active toggle when event is active', function(assert) {
  let scheduledEvent = FactoryGuy.make('scheduled-event', {
    name: 'Pre Event',
    dispatchAt: moment(this.get('dueDate')).add(2, 'days')
  });
  this.set('event', scheduledEvent);
  this.render(hbs `{{scheduled-event-status event=event}}`);
  assert.textPresent('.scheduled-event p', '2 days after due date');
});
