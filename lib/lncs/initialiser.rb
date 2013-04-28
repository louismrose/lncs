module LNCS
  class Initialiser
    include Thor::Actions
    
    def initialize(dir)
      @dir = dir
    end
    
    def run
      create_manifest
    end
  
  private
    def create_manifest
      copy_file '../../templates/manifest.json', File.join(@dir, 'manifest.json')
    end
  end
end