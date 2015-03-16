module InitialTechCheck
  class InitialTechCheckTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    register_task default_title: "InitialTechCheck Task", default_role: "author"

    def active_model_serializer
      InitialTechCheck::InitialTechCheckTaskSerializer 
    end
  end
end
