require "thor"

module LNCS
  class Actions < Thor
    include Thor::Actions
    
    def initialize(sources, args = [], options = {}, config = {})
      super(args, options, config)
      @source_paths = [sources]
    end
    
    no_commands do
      def source_paths
        @source_paths
      end
    end
  end
end