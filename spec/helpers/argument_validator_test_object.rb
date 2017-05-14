module RocciCoreSpec
  class ArgumentValidatorTestObject
    include Occi::Core::Helpers::ArgumentValidator
    include Yell::Loggable

    private

    def sufficient_args!(args)
      raise 'Missing required arg' unless args[:val]
    end

    def defaults
      {
        text: 'text',
        val: nil
      }
    end
  end
end
