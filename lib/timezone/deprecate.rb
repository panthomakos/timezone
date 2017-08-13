# frozen_string_literal: true

module Timezone
  # This class provides a way to set a custom hook for deprecations.
  module Deprecate
    class << self
      # Set the custom deprecation callback. By default this
      # issues a deprecation warning.
      #
      # @param callback [#call] the custom callback
      #
      # @example Send a message to StatsD
      #   Timezone::Deprecate.callback = lambda do |klass, method, _|
      #     StatsD.increment(sanitize(klass, method))
      #   end
      #
      # @example Send a message to a custom logger
      #   Timezone::Deprecate.callback = lambda do |klass, method, msg|
      #     MyLogger.log("[#{klass} : #{method}] #{msg}")
      #   end
      attr_writer :callback

      # @!visibility private
      def callback
        @callback || ->(_, _, message) { warn(message) }
      end

      # @!visibility private
      def call(klass, method, message)
        callback && callback.call(klass, method, message)
      end
    end
  end
end
