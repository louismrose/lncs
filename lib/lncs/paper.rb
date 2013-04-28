require "tmpdir"
require "pdf-reader"
require "zip/zipfilesystem"

module LNCS
  class Paper
    def initialize(path, paper)
      @path = path
      @pdf = paper["pdf"]
      @title = paper["title"]
      @authors = paper["authors"]
    end
  
    def name
      File.basename(@path)
    end
  
    def id
      name.match(/(\d+).(pdf|zip)/)[1]
    end
  
    def type
      name.match(/(pdf|zip)/)[1]
    end
  
    def generate_title_to(dst, start_page)
      raise "Cannot generate title from PDF for paper ##{id}" if type == "pdf"
    
      captured = title_page
      captured += "\n" + authors.map{ |a| "\\index{#{a}}"}.join("\n") + "\n"
    
      captured += "\\maketitle\n"
      captured += "\\clearpage\n"
      captured += "\\setcounter{page}{#{start_page + page_count}}"
    
      FileUtils.mkdir_p(File.dirname(dst))
      File.open(dst, 'w') {|f| f.write(captured) }
    end
  
    def copy_to(dst)
      FileUtils.mkdir_p(dst)
    
      if type == "zip"
        Zip::ZipFile.open(@path) do |zipfile|
          zipfile.each do |file|
            FileUtils.mkdir_p(File.dirname(File.join(dst, file.name)))
            zipfile.extract(file, File.join(dst, file.name))
          end
        end
      else
        FileUtils.copy_file(@path, File.join(dst, name))
      end
    
      @copied = dst
    end
  
    def pdf
      if type == "zip"
        extracted_pdf = File.join(Dir.tmpdir, @pdf)
        Zip::ZipFile.open(@path) do |zipfile|
          FileUtils.mkdir_p(File.dirname(extracted_pdf))
          zipfile.extract(@pdf, extracted_pdf) { true }
        end
        File.open(extracted_pdf, "rb")
      else
        File.open(@path, "rb")
      end
    end
  
    def page_count
      PDF::Reader.new(pdf).page_count
    end
  
    def authors
      if @authors
        @authors.map do |a|
          a.gsub(/(?<forename>\S*) (?<surname>.*)/, '\k<surname>, \k<forename>')
        end
      else
        regex = %r{
          \\author(?<re>
            \{
              (?:
                (?> [^{}]+ )
                |
                \g<re>
              )*
            \}
          )
        }x
      
        if regex.match(title_page)
          author_tag = regex.match(title_page)[1]
          author_tag = author_tag[1..-2]                  # strip starting and closing bracket
          author_tag.gsub! /\\\\/, ''                     # strip forced linebreaks
          author_tag.gsub! /\\inst\{[^\}]*?\}/, ''         # strip institutions
          author_tag.split('\and').map do |a|
            a.strip!
            a.gsub(/(?<forename>\S*) (?<surname>.*)/, '\k<surname>, \k<forename>')
          end
        else
          []
        end
      end
    end
  
    def title_page
      if @title
  """
  \\title{#{@title}}\n
  \\author{#{@authors.join(" \\and ")}}\n
  """
      else
        captured = ""
        each_tex do |tex|
          capturing = false
          while (line = tex.gets)
            break if line.include? '\maketitle'
            captured += line if capturing and not line.include? '\frontmatter' and not line.include? '\mainmatter'
            capturing = true if line.include? '\begin{document}'
          end
        end
        captured.gsub /\\mails[a-z](\\\\)?/, '$ $'  # remove any \mailsa or similar commands
      end
    end
  
    def each_tex
      if type == "zip"
        Zip::ZipFile.open(@path) do |zipfile|
          zipfile.each do |file|
            if file.name.end_with? "tex" and not file.name.end_with? "llncs.tex"
              extracted_tex = File.join(Dir.tmpdir, file.name)
              FileUtils.mkdir_p(File.dirname(extracted_tex))
              zipfile.extract(file, extracted_tex) { true }
              File.open(extracted_tex, "rb") { |file| yield(file) }
            end
          end
        end
      end
    end
  end
end