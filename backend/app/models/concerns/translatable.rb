module Translatable
  extend ActiveSupport::Concern

  LOCALES = %w[en id].freeze
  DEFAULT_LOCALE = "en".freeze

  class_methods do
    # Declares which columns can carry a translation. The base column holds the
    # default locale; `translations` holds overrides for the others.
    def translates(*fields)
      @translatable_fields = fields.map(&:to_s)
    end

    def translatable_fields
      @translatable_fields || []
    end
  end

  # Returns the value for this locale, falling back to the base column whenever
  # the override is missing or blank. A partly translated record therefore
  # renders completely rather than showing gaps.
  def translated(field, locale = DEFAULT_LOCALE)
    name = field.to_s
    return self[name] unless self.class.translatable_fields.include?(name)
    return self[name] if locale.blank? || locale.to_s == DEFAULT_LOCALE

    override = translations.dig(locale.to_s, name)
    override.presence || self[name]
  end

  def translated_locales
    translations.keys & LOCALES
  end
end
