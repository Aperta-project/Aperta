Subscriptions.configure do
  add 'paper:submitted', PlosBilling::Paper::Salesforce
  add 'paper:accepted', PlosBilling::Paper::Salesforce
  add 'paper:rejected', PlosBilling::Paper::Salesforce
  add 'paper:withdrawn', PlosBilling::Paper::Salesforce
end
