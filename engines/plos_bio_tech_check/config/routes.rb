PlosBioTechCheck::Engine.routes.draw do
  post "initial_tech_check/:id/send_email", controller: "initial_tech_check", action: "send_email", as: :send_itc_email

  post "revision_tech_check/:id/send_email", controller: "revision_tech_check", action: "send_email", as: :send_rtc_email

  post "final_tech_check/:id/send_email", controller: "final_tech_check", action: "send_email", as: :send_ftc_email
end
