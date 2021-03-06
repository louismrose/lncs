require 'tmpdir'
require 'pdf-reader'
require 'zip/zipfilesystem'
require 'lncs/actions'

module LNCS
  class Paper
    attr_accessor :manifest, :path, :proceedings
    
    def pdf
      manifest["pdf"]
    end
    
    def title
      manifest["title"]
    end
    
    def authors
      manifest["authors"]
    end
  
    def name
      File.basename(path)
    end
  
    def id
      name.match(/(\d+).(pdf|zip)/)[1]
    end
  
    def type
      name.match(/(pdf|zip)/)[1]
    end
  
    def generate_title_to(dst, start_page)
      check_pdf_exists
    
      captured = title_page_from_manifest_or_latex
      captured += "\n" + authors_from_manifest_or_latex.map do |a| 
        a.gsub!(/(?<forename>\S*) (?<surname>.*)/, '\k<surname>, \k<forename>') if a   
        "\\index{#{a}}"
      end.join("\n") + "\n"
    
      captured += "\\maketitle\n"
      captured += "\\clearpage\n"
      captured += "\\setcounter{page}{#{start_page + page_count}}"
    
      actions.create_file(dst, captured)
    end
  
    def copy_to(dst)
      FileUtils.mkdir_p(dst)
    
      if type == "zip"
        Zip::ZipFile.open(path) do |zipfile|
          zipfile.select { |file| zipfile.get_entry(file).file? }.each do |file|
            actions.create_file(File.join(dst, file.name), zipfile.read(file))
          end
        end
      else
        actions.copy_file(path, File.join(dst, name))
      end
    end
    
    def data_for_manifest(existing_data)
      if existing_data.key?(id)
        { id => existing_data[id] }
        
      elsif type == "zip"
        data = { pdf: paths_to_pdfs }
        
        case data[:pdf].size
        when 1
          data[:pdf] = data[:pdf].first
        when 0
          data[:FIXME] = "Change the PDF key to the path (relative, within the ZIP) of the compiled PDF."
        else
          data[:FIXME] = "Reduce the PDF key from an array to a single value which corresponds to the compiled PDF." 
        end

        { id => data }
      
      else
        {}
      end
    end
  
    def page_count
      check_pdf_exists
      
      PDF::Reader.new(open_pdf).page_count
    end
  
  private
    def check_pdf_exists
      raise "Error: no file found at path '#{path}'" unless File.exist?(path)
      
      if type == "zip"
        pdf_exists = Zip::ZipFile.open(path) { |zipfile| zipfile.find_entry(pdf) }
        raise "Error: no PDF file found at path '#{pdf}' within the ZIP file #{path}" unless pdf_exists  
      end
    end
    
    # Locate all PDF files within the ZIP
    def paths_to_pdfs
      paths = []
      
      Zip::ZipFile.open(path) do |zipfile|
        zipfile.select { |file| zipfile.get_entry(file).file? }.each do |file|
          paths << file.name if file.name.end_with? ".pdf"
        end
      end
      
      paths
    end
    
    def open_pdf      
      if type == "zip"
        extracted_pdf = File.join(Dir.tmpdir, pdf)
        Zip::ZipFile.open(path) do |zipfile|
          FileUtils.mkdir_p(File.dirname(extracted_pdf))
          zipfile.extract(pdf, extracted_pdf) { true }
        end
        File.open(extracted_pdf, "rb")
      else
        File.open(path, "rb")
      end
    end
    
    def authors_from_manifest_or_latex
      if authors
        authors
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
      
        title_page = title_page_from_manifest_or_latex
        if regex.match(title_page)
          author_tag = regex.match(title_page)[1]
          author_tag = author_tag[1..-2]                  # strip starting and closing bracket
          author_tag.gsub! /\\\\/, ''                     # strip forced linebreaks
          author_tag.gsub! /\\inst\{[^\}]*?\}/, ''         # strip institutions
          author_tag.split('\and').map do |a|
            a.strip!
          end
        else
          []
        end
      end
    end
  
    def title_page_from_manifest_or_latex
      if title
  """
  \\title{#{title}}\n
  \\author{#{authors_from_manifest_or_latex.join(" \\and ")}}\n
  """
      else
        raise "Error: lncs cannot extract title and authors from a PDF file. Please specify the title and authors in the manifest for paper ##{id})" if type == "pdf"
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
        Zip::ZipFile.open(path) do |zipfile|
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
  
    def actions
      Actions.new(proceedings.source_directory)
    end
  end
end