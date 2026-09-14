module Blueprinter
  # Rails models are snake_case; the TypeScript client expects camelCase.
  # Registered as a default transformer so every blueprint emits camelCase keys
  # without each field having to spell out a :name override.
  class CamelCaseTransformer < Transformer
    def transform(result_hash, _primary_obj, _options = {})
      result_hash.transform_keys! { |key| camelize(key) }
    end

    private

    def camelize(key)
      parts = key.to_s.split("_")
      return key if parts.one?

      (parts.first + parts[1..].map(&:capitalize).join).to_sym
    end
  end
end
