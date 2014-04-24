require "thor"
require "json"

module LNCS
  class CLI < Thor
    include Thor::Actions
    
    desc "init", "Start an lncs project in the current directory"
    def init
      Initialiser.new.run
    end
    
    desc "clean", "Remove all working directories"
    def clean
      working_directories = %w{submissions body titles}
      working_directories.each {|d| remove_dir(d) }
      create_file 'titles/index.tex'
    end

    desc "inspect", "Inspect the submissions and prepare manifest for the lncs report, body and titles subcommands."
    def inspect
      remake_directory("submissions")
      proceedings.copy_to("submissions")
      proceedings.add_papers_to_manifest
    end

    desc "body", "Generate the set of directories containing the body of the report, in the format required by Springer LNCS"
    def body
      remake_directory("body")
      proceedings.generate_body_to("body")
    end

    desc "titles", "Generate a title page for each submission, including correct page numbers and author index entries"
    def titles
      remake_directory("titles")
      proceedings.generate_titles_to("titles")
    end

    desc "report", "Print useful statistics about the submissions"
    def report
      proceedings.report
    end

private
    def remake_directory(dir)
      remove_dir dir
      empty_directory dir
    end
    
    def proceedings
      manifest_missing unless File.exist?("manifest.json")
      Proceedings.new.tap do |p|
        p.manifest = JSON.parse(File.read("manifest.json"))
      end
    end
    
    def manifest_missing
      puts "Error: lncs could not find a manifest.json file in the current directory."
      puts "You can use 'lncs init' to create a basic manifest file."
      exit 1
    end
  end
end