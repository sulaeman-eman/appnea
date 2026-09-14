require "blueprinter/camel_case_transformer"

Blueprinter.configure do |config|
  config.default_transformers = [ Blueprinter::CamelCaseTransformer ]
  config.datetime_format = ->(datetime) { datetime.iso8601 }
end
