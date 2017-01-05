import Ember from 'ember';
import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup }  from 'ember-data-factory-guy';
import sinon from 'sinon';
import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('orcid-connect',
                   'Integration | Component | orcid connect',
                   {integration: true,
                    beforeEach: function() {
                      manualSetup(this.container);
                      this.set('confirm', (message)=>{});
                    }});

var template = hbs`{{orcid-connect orcidAccount=orcidAccount confirm=confirm open=open journal=1 canRemoveOrcid=true}}`;

test("component shows connect to orcid before a user connects to orcid", function(assert){
  let orcidAccount = FactoryGuy.make('orcid-account');

  this.set('orcidAccount', orcidAccount);
  this.render(template);

  assert.textPresent('.orcid-not-linked > button', 'Connect or create your ORCID ID');
});

test('component disables button when popup is open, and enables button when it is closed', function(assert){
  assert.expect(4);
  const isDisabled = (selector)=>{
    return this.$(selector).first().attr('disabled') === 'disabled';
  };
  const buttonSelector = '.orcid-not-linked > .connect-orcid';
  let orcidAccount = FactoryGuy.make('orcid-account');

  let openObject = {closed: false};
  let open = sinon.stub().returns(openObject);
  this.set('open', open);
  this.set('openObject', openObject);

  this.set('orcidAccount', orcidAccount);
  this.render(template);

  assert.ok(
    isDisabled(buttonSelector) === false,
    'Button is not disabled before clicking'
  );

  this.$(buttonSelector).click();
  assert.spyCalled(open);

  let done1 = assert.async();
  Ember.run.later(this, ()=>{
    assert.ok(
      isDisabled(buttonSelector) === true,
      'Button is disabled after clicking'
    );
    done1();
  });

  // simulate closing the popup window.
  this.get('openObject')['closed'] = true;
  let done2 = assert.async();
  Ember.run.later(this, ()=>{
    assert.ok(
      isDisabled(buttonSelector) === false,
      'Button is not disabled after popup is closed'
    );
    done2();
    // Waiting 300ms to ensure we've given the orcid-connect component to test
    // the `closed` property at least once.
  }, 300);
});

test("component shows orcid id and trash can when a user is connected to orcid", function(assert){
  let orcidAccount = FactoryGuy.make('orcid-account', {
    'status': 'authenticated',
    'identifier': '0000-0000-0000-0000'
  });

  this.set('orcidAccount', orcidAccount);
  this.render(template);
  assert.elementFound('.orcid-linked');
  assert.elementFound('.remove-orcid');
});

test("component shows orcid id and trash can, and reauthorize option if accessTokenExpired", function(assert){
  let orcidAccount = FactoryGuy.make('orcid-account', {
    'status': 'access_token_expired',
    'identifier': '0000-0000-0000-0000'
  });
  let user = FactoryGuy.make('user');

  this.set('user', user);
  this.set('currentUser', user);
  this.set('orcidAccount', orcidAccount);
  this.render(template);
  assert.elementFound('.orcid-access-expired');
  assert.elementFound('.remove-orcid');
});

test("user can click on trash icon, and say 'No, I don't want to remove my ORCID record'", function(assert){
  // Simulate user saying 'No' in the confirm dialog for removing their
  // ORCID record
  let confirm = sinon.stub().returns(false);
  this.set('confirm', confirm);

  let orcidAccount = FactoryGuy.make('orcid-account', {
    'status': 'authenticated',
    'identifier': '0000-0000-0000-0000'
  });

  assert.ok(orcidAccount.clearRecord, "clearRecord exists");
  orcidAccount.clearRecord = sinon.stub()

  this.set('orcidAccount', orcidAccount);
  this.render(template);
  this.$('.remove-orcid').click();
  assert.spyCalledWith(confirm, ["Are you sure you want to remove your ORCID record?"]);
  assert.spyNotCalled(orcidAccount.clearRecord, "clearRecord was not called.");
});

test("user can click on trash icon, and say 'Yes, I do want to remove my ORCID record'", function(assert){
  $.mockjax({
    url: "/api/orcid_accounts/1/clear",
    type: 'PUT',
    status: 200,
    responseText: { "orcid_account": {"id":1, "identifier":null} }}
  );

  // Simulate user saying 'Yes' in the confirm dialog for removing their
  // ORCID record
  let confirm = sinon.stub().returns(true);
  this.set('confirm', confirm);

  let orcidAccount = FactoryGuy.make('orcid-account', {
    'status': 'authenticated',
    'identifier': '0000-0000-0000-0000'
  });

  this.set('orcidAccount', orcidAccount);
  this.render(template);
  this.$('.remove-orcid').click();

  // done + wait().then(...) is used so a promise can be resolved for the
  // above mocked out HTTP PUT to /api/orcid_accounts/1/clear,
  let done = assert.async();
  wait().then(() => {
    assert.spyCalledWith(confirm, ["Are you sure you want to remove your ORCID record?"]);

    // The promise returned by the restless call inside of clearRecord is resolving after the test runs :(
    assert.textPresent('.orcid-not-linked > button', 'Connect or create your ORCID ID');
    done();
  });
});

var noUserTemplate = hbs`{{orcid-connect user=user currentUser=currentUser orcidAccount=orcidAccount confirm=confirm journal=1 canRemoveOrcid=true}}`;

test("component works when user is not set and then set", function(assert) {
  let orcidAccount = FactoryGuy.make('orcid-account', {
    'status': 'access_token_expired',
    'identifier': '0000-0000-0000-0000'
  });

  let user = FactoryGuy.make('user', {
    id: '1'
  });

  this.set('currentUser', user);

  this.render(noUserTemplate);
  assert.elementNotFound('.orcid-wrapper');
  this.set('user', user);
  this.set('orcidAccount', orcidAccount);
  assert.elementFound('.orcid-wrapper');
});

test("users are only allowed to link their ORCID accounts", function(assert) {
  let user = FactoryGuy.make('user', {
    id: '1'
  });

  let viewer = FactoryGuy.make('user', {
    id: '2'
  });

  this.set('currentUser', viewer);

  this.render(noUserTemplate);
  assert.elementNotFound('.orcid-wrapper');
  this.set('user', user);
  assert.elementNotFound('.orcid-wrapper');
});
