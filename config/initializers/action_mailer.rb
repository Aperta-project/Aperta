# Register the MailLoggerObserver class
ActionMailer::Base.register_observer(EmailLoggerObserver)
ActionMailer::Base.register_interceptor(LogEmailsToDatabaseInterceptor)
ActionMailer::Base.register_observer(LogEmailsToDatabaseObserver)
