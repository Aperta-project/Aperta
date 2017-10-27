module TahiStandardTasks
  class PreprintDecisionScenario < TemplateContext
    context :journal
    context :paper, as: :manuscript, source: 'object'
  end
end
