namespace 'nested-questions' do
  desc "Seed all of the nested questions"
  task seed: [
    'nested-questions:seed:author',
    'nested-questions:seed:authors-task',
    'nested-questions:seed:competing-interests-task',
    'nested-questions:seed:cover-letter-task',
    'nested-questions:seed:data-availability-task',
    'nested-questions:seed:ethics-task',
    'nested-questions:seed:figure-task',
    'nested-questions:seed:financial-disclosure-task',
    'nested-questions:seed:funder',
    'nested-questions:seed:group-author',
    'nested-questions:seed:plos-billing-task',
    'nested-questions:seed:production-metadata-task',
    'nested-questions:seed:publishing-related-questions-task',
    'nested-questions:seed:register-decision-task',
    'nested-questions:seed:reporting-guidelines-task',
    'nested-questions:seed:reviewer-recommendation',
    'nested-questions:seed:reviewer-report-task',
    'nested-questions:seed:front-matter-reviewer-report-task',
    'nested-questions:seed:taxon-task',
    'nested-questions:seed:plos-bio-initial-tech-check-task',
    'nested-questions:seed:plos-bio-revision-tech-check-task',
    'nested-questions:seed:plos-bio-final-tech-check-task'
  ]
end
