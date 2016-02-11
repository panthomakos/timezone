module Timezone
  # TODO: Documentation
  module Deprecate
    class << self
      attr_writer :callback

      def callback
        @callback || -> (_, _, message) { warn(message) }
      end

      def call(klass, method, message)
        callback && callback.call(klass, method, message)
      end
    end
  end
end
