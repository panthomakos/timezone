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
      'NilZone'.freeze
    end

    # A stubbed timezone debug string.
    #
    # @return [String]
    def inspect
      '#<Timezone::NilZone>'.freeze
    end

    # Whether or not this timezone exists.
    #
    # @return [false]
    def exists?
      false
    end
  end
end
