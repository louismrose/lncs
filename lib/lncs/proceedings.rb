module LNCS
  class Proceedings
    attr_reader :sections
  
    def initialize(manifest)
      @sections = []
      @volume_number = manifest["volume_number"]
    
      @sections = manifest["sections"].map do |section|
        Section.new(section, manifest["sources"], manifest["papers"])
      end
    end
  
    def copy_to(dst)
      sections.each { |section| section.copy_to(dst) }
    end
  
    def generate_body_to(dst)
      start_page = 1
      @sections.each do |s|
        start_page = s.generate_body_to(dst, @volume_number, start_page)
      end
    end
  
    def generate_titles_to(dst)
      FileUtils.rm_rf("#{dst}/index.tex") if File.exists?("#{dst}/index.tex")
      start_page = 1
      @sections.each do |s|
        start_page = s.generate_titles_to(dst, start_page)
      end
    end
  
    def report
      @sections.each { |s| s.report }
    end
  end
end