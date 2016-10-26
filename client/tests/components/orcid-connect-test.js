import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup }  from 'ember-data-factory-guy';

import hbs from 'htmlbars-inline-precompile';


moduleForComponent('orcid-connect',
                   'Integration | Component | orcid connect',
                   {integration: true,
                    beforeEach: function() {
                      manualSetup(this.container)
                    }});

var template = hbs`{{orcid-connect orcidAccount=orcidAccount}}`;

test("component shows connect to orcid before a user connects to orcid", function(assert){
  let orcidAccount = FactoryGuy.make('orcid-account');

  this.set('orcidAccount', orcidAccount);
  this.render(template);

  assert.textPresent('.orcid-not-linked > button', 'Connect or create your ORCID ID');
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

  this.set('orcidAccount', orcidAccount);
  this.render(template);
  assert.elementFound('.orcid-access-expired');
  assert.elementFound('.remove-orcid');
});

test("clicking on the trash icon calls clear record", function(assert){
  assert.expect(2);

  let orcidAccount = FactoryGuy.make('orcid-account', {
    'status': 'authenticated',
    'identifier': '0000-0000-0000-0000'
  });

  assert.ok(orcidAccount.clearRecord, "clearRecord exists");
  orcidAccount.clearRecord = function(){assert.ok("clearRecord was called");};

  this.set('orcidAccount', orcidAccount);
  this.render(template);

  this.$('.remove-orcid').click();
});
