class TahiEnv
  # DslMethods houses the DSL methods for registering ENV variables that the
  # application knows about.
  module DslMethods
    # Expose a singleton-like interface for accessing an instance of TahiEnv
    # since we only need one.
    #
    # Note: Don't use Singleton from Ruby standard library since that prevents
    # us from creating TahiEnv instances in corresponding specs/tests.
    def instance
      @instance ||= TahiEnv.new
    end

    # +optional+ registers an optional ENV var with the given key.
    #
    # == Examples
    #
    #    optional :FOO
    #    optional :FOO, :boolean, default: false
    def optional(key, type = nil, default: nil)
      optional_env_var = OptionalEnvVar.new(
        key,
        type,
        default: default
      )
      register_env_var(optional_env_var)
    end

    # +required+ registers a required ENV var with the given key. It supports
    # ActiveModel#validate options.
    #
    # == Examples
    #
    #    required :BAR
    #    required :BAR, :boolean
    #    required :BAR, :boolean, if: :some_other_value?
    #
    def required(key, *args)
      options = args.extract_options!
      type = args.first
      default_value = options[:default]
      if_method = options[:if]

      additional_details = "if #{if_method}" if if_method
      required_env_var = RequiredEnvVar.new(
        key,
        type,
        default: default_value,
        additional_details: additional_details
      )
      register_env_var(required_env_var)

      validation_args = required_env_var.boolean? ? { boolean: true } : { presence: true }

      validation_args[:if] = if_method if if_method
      validates key, **validation_args
    end

    # Override method_missing to perform a look-up on TahiEnv.instance. Every
    # method_missing call is assumed to be an ENV var lookup.
    #
    #    TahiEnv.foo_enabled? -> TahiEnv.instance.foo_enabled?
    #
    # If TahiEnv.instance does not respond to the given method a
    # MissingEnvVarRegistration error will be raised.
    def method_missing(method, *args, &blk)
      if instance.respond_to?(method)
        instance.send(method, *args, &blk)
      else
        method = method.to_s
        fail MissingEnvVarRegistration, <<-ERROR_MSG.strip_heredoc
          undefined method #{method.inspect} for #{self}. Is the
          #{method.upcase} env var registered in #{self}?
        ERROR_MSG
      end
    end

    # Returns the registered list of environment variables.
    def registered_env_vars
      @registered_env_vars = @registered_env_vars || {}
    end

    protected

    # +register_env_var+ registers a TahiEnv::EnvVar instance and defines
    # reader method(s) for it.
    #
    # Say there's a boolean EnvVar with a key of 'FOO_ENABLED'. Registering it
    # will generate two methods:
    #
    #   * FOO_ENABLED - a reader method that returns the raw value of the ENV variable
    #   * foo_enabled? - a query method that returns the boolean value
    #
    # Next, Say there's a EnvVar without a type with a key of 'BAR'.
    # Registering it will generate two methods:
    #
    #   * BAR - a reader method that returns the raw value of the ENV variable
    #   * bar - a query method that returns raw value
    #
    def register_env_var(env_var)
      registered_env_vars[env_var.key] = env_var

      # TahiEnv#APP_NAME
      reader_method_name = env_var.key
      define_method(reader_method_name) do
        env_var.raw_value_from_env
      end

      # TahiEnv#app_name
      # TahiEnv#orcid_enabled? for boolean
      reader_method_name = "#{env_var.key.downcase}"
      reader_method_name << "?" if env_var.boolean?
      define_method(reader_method_name) do
        env_var.value
      end
    end
  end
end
