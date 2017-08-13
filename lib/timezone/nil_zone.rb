# frozen_string_literal: true

module Timezone
  # A "nil" timezone object - representative of a missing timezone.
  class NilZone
    # A stubbed timezone name.
    #
    # @return [nil]
    def name
      nil
    end

    # A stubbed timezone display string.
    #
    # @return [String]
    def to_s
      'NilZone'
    end

    # A stubbed timezone debug string.
    #
    # @return [String]
    def inspect
      '#<Timezone::NilZone>'
    end

    # If this is a valid timezone.
    #
    # @return [false]
    def valid?
      false
    end
  end
end
