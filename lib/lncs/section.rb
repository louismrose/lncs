require_relative "paper"

module LNCS
  class Section
    attr_reader :papers
  
    def initialize(section, source_directory, papers)
      @papers = []
      @title = section["title"]
    
      Dir.chdir(directory) do
        section["papers"].each do |paper_id|
          Dir.glob("*_#{paper_id}.{pdf,zip}") do |file|
            path = File.join(source_directory, file)
          
            paper = papers.fetch(paper_id.to_s, {})
            paper["pdf"] = file unless paper["pdf"]
          
            @papers << Paper.new(path, paper)
          end
        end
      end
    end
  
    def copy_to(dst)
      papers.each { |paper| paper.copy_to("#{dst}/#{paper.id}") }
    end
  
    def generate_body_to(dst, volume_number, start_page)
      papers.each do |paper|
        padded_start_page = "%04d" % start_page.to_s
        paper.copy_to("#{dst}/#{volume_number}#{padded_start_page}")  
        start_page += paper.page_count
      end
      start_page
    end
  
    def generate_titles_to(dst, start_page)
      titles = []
      papers.each do |paper|
        padded_start_page = "%04d" % start_page.to_s
        titles << "#{dst}/#{padded_start_page}.tex"
        paper.generate_title_to(titles.last, start_page)
        start_page += paper.page_count
      end
    
      File.open("#{dst}/index.tex", 'a') do |f|
        f.write("\\addtocmark{#{@title}}\n")
        f.write(titles.map {|title| "\\input{#{title}}\n"}.join)
      end
    
      start_page
    end
  
    def report
      puts @title
      papers.each { |paper| puts "#{"%03d" % paper.id} -- #{paper.page_count}pgs #{paper.type}" }
    end
  end
end