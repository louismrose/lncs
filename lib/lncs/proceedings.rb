module LNCS
  class Proceedings
    attr_accessor :manifest
    
    def volume_number
      manifest["volume_number"]
    end
  
    def source_directory
      manifest["sources"]
    end
  
    def papers
      manifest["papers"]
    end
  
    def paper_file_name_for(paper_id)
      Dir.chdir(source_directory) do
        Dir.glob("*_#{paper_id}.{pdf,zip}")[0]
      end
    end
  
    def paper_path_for(paper_id)
      File.join(source_directory, paper_file_name_for(paper_id))
    end
  
    def paper_manifest_for(paper_id)
      paper_manifest = papers.fetch(paper_id.to_s, {})
      paper_manifest["pdf"] = paper_file_name_for(paper_id) unless paper_manifest["pdf"]
      paper_manifest
    end
  
    def sections
      manifest["sections"].map do |section|
        Section.new.tap do |s|
          s.manifest = section
          s.proceedings = self
        end
      end
    end

    def copy_to(dst)
      sections.each { |section| section.copy_to(dst) }
    end

    def generate_body_to(dst)
      start_page = 1
      sections.each do |s|
        start_page = s.generate_body_to(dst, volume_number, start_page)
      end
    end

    def generate_titles_to(dst)
      actions.remove_file("#{dst}/index.tex")
      actions.create_file("#{dst}/index.tex")
      start_page = 1
      sections.each do |s|
        start_page = s.generate_titles_to(dst, start_page)
      end
    end

    def report
      sections.each { |s| s.report }
    end

  private
    def actions
      Actions.new
    end
  end
end