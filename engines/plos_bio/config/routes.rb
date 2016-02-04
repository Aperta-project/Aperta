PlosBio::Engine.routes.draw do
  post 'changes_for_author/:id/send_email',
       controller: 'changes_for_author',
       action: 'send_email',
       as: :send_email

  post 'changes_for_author/:id/submit_tech_check',
       controller: 'changes_for_author',
       action: 'submit_tech_check',
       as: :submit_tech_check

  post 'initial_tech_check/:id/send_email',
       controller: 'initial_tech_check',
       action: 'send_email',
       as: :send_itc_email

  post 'revision_tech_check/:id/send_email',
       controller: 'revision_tech_check',
       action: 'send_email',
       as: :send_rtc_email

  post 'final_tech_check/:id/send_email',
       controller: 'final_tech_check',
       action: 'send_email',
       as: :send_ftc_email
end
