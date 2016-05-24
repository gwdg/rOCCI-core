RSpec::Matchers.define :have_attr_reader_only do |field|
  match do |object_instance|
    object_instance.respond_to?(field) && !object_instance.respond_to?("#{field}=")
  end

  failure_message do |object_instance|
    "expected only attr_reader for #{field} on #{object_instance}"
  end

  failure_message_when_negated do |object_instance|
    "expected only attr_reader for #{field} not to be defined on #{object_instance}"
  end

  description do
    'assert there is only attr_reader of the given name on the supplied object'
  end
end
