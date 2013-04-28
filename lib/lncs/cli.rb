require "thor"
require "json"

module LNCS
  class CLI < Thor
    desc "clean", "Remove all working directories"
    def clean
      working_directories = %w{content, submissions, title}
      working_directories.each {|d| remove_directory(d) }
    end

    desc "inspect", "Unpack the submissions so that their contents can be inspected manually"
    def inspect
      remake_directory("submissions")
      proceedings.copy_to("submissions")
    end

    desc "compile", "Compile the submissions, forming the directory structure required by LNCS"
    def compile
      remake_directory("content")
      proceedings.compile_to("content")
    end

    desc "toc", "Generate an entry in the table of contents for each submission"
    def toc
      remake_directory("title")
      proceedings.generate_titles_to("title")
    end

    desc "report", "Print useful statistics about the submissions"
    def report
      proceedings.report
    end

private
    def remake_directory(dir)
      remove_directory(dir)
      Dir.mkdir(dir)
    end
    
    def remove_directory(dir)
      FileUtils.rm_rf(dir) if Dir.exists?(dir)
    end
    
    def proceedings
      manifest_missing unless File.exist?("manifest.json")
      Proceedings.new(JSON.parse(File.read("manifest.json")))
    end
    
    def manifest_missing
      puts "Error: lncs could not find a manifest.json file in the current directory."
      puts "You can use 'lncs init' to create a basic manifest file."
      exit 1
    end
  end
end