module LNCS
  class Section
    attr_accessor :manifest, :proceedings
  
    def papers
      manifest["papers"].map do |paper_id|      
        Paper.new.tap do |p|
          p.manifest = proceedings.paper_manifest_for(paper_id)
          p.path = proceedings.paper_path_for(paper_id)
        end
      end
    end
    
    def title
      manifest["title"]
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
        f.write("\\addtocmark{#{title}}\n")
        f.write(titles.map {|title| "\\input{#{title}}\n"}.join)
      end
    
      start_page
    end
  
    def report
      puts title
      papers.each { |paper| puts "#{"%03d" % paper.id} -- #{paper.page_count}pgs #{paper.type}" }
    end
  end
end