module LNCS
  class Initialiser < Thor
    include Thor::Actions
    
    def self.source_root
      File.join(File.dirname(__FILE__), '..', '..', 'templates')
    end
    
    no_commands do
      def run
        copy_file 'manifest.json'
        copy_file 'main.tex'
        copy_file 'llncs.cls'
        copy_file 'sprmindx.sty'
        copy_file 'front_matter/organisation.tex'
        copy_file 'front_matter/preface.tex'
        copy_file 'front_matter/sponsors.tex'
      end
    end
  end
end