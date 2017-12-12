task 'create_feature_flags': :environment do
  # To create a new feature flag, simply add it to the list and run `rake create_feature_flags`. By
  # convention, feature flags are in ALL_CAPS_SNAKE_CASE.
  #
  # To eliminate a flag, just remove it from this list. Beware,
  # though! You must remove ALL REFERENCES to the flag BEFORE you
  # remove it from this list!
  #
  # See the FeatureFlag model for more usage information.
  #
  FeatureFlag.contain_exactly! [
    "CARD_CONFIGURATION",
    "HEALTH_CHECK",
    "CAS_PHASED_SIGNUP",
    "KEEP_APEX_HTML",
    "PREPRINT",
    "JIRA_INTEGRATION"
  ]
end
