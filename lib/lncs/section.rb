require_relative "paper"

module LNCS
  class Section
    attr_reader :papers
  
    def initialize(directory, indexes, titles, section)
      @papers = []
      @name = section["name"]
    
      Dir.chdir(directory) do
        section["ids"].each do |id|
          Dir.glob("*_#{id}.{pdf,zip}") do |file|
            path = File.join(directory, file)
          
            # Use the index as the name of the PDF.
            # If no index is specified for this ID use
            # the name of the file (which we assume is a PDF)
            index = indexes.fetch(id.to_s, file)
            title = titles.fetch(id.to_s, nil)
          
            @papers << Paper.new(path, index, title)
          end
        end
      end
    end
  
    def copy_to(dst)
      papers.each { |paper| paper.copy_to("#{dst}/#{paper.id}") }
    end
  
    def compile_to(dst, volume_number, start_page)
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
        f.write("\\addtocmark{#{@name}}\n")
        f.write(titles.map {|title| "\\input{#{title}}\n"}.join)
      end
    
      start_page
    end
  
    def report
      puts @name
      papers.each { |paper| puts "#{"%03d" % paper.id} -- #{paper.page_count}pgs #{paper.type}" }
    end
  end
end