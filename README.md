LNCS Volume Editor Tools
========================
A small set of tools that automate some of the more tedious parts of preparing an LNCS volume.

The conventions enforced by `lncs` are intended to comply with the LNCS guidelines for volume editors. If you find an inconsistency between `lncs` and the LNCS guidelines, please [file a bug report](https://github.com/louismrose/lncs/issues).

Installation
------------
You'll need to install Ruby 1.9 or later. I recommend doing so via [rvm](https://rvm.io).

You can then install `lncs` via Ruby gems: `gem install lncs`

Recommended workflow
--------------------
Creating a Springer LNCS proceedings with `lncs` involves two activities: ensuring that `lncs` has sufficient information about your proceedings and submissions (steps 1-5, below), and using `lncs` to generate all of the artefacts that Springer require for an LNCS proceedings (steps 7-11).

1. Download the submissions for your proceedings (e.g., from EasyChair). Please note that:
    * `lncs` works best for submissions that are packaged as a single ZIP file that contains both the LaTeX source and a compiled PDF.
    * `lncs` can also be used for submissions that do not include LaTeX source files, or that are packaged as a single PDF file. For submissions that do not include LaTeX source files, you will need to specify some extra information in the manifest (more details below). 
    * `lncs` does not work with submissions packages as MS Word files.

2. Create a new working directory:

        > mkdir ecmfa2013
        > cd ecmfa2013
        > lncs init    

3. Setup the manifest (e.g., set the path to the submissions, the volume number, ...)

        > vi manifest.json
        > cat manifest.json
        {
          "volume_number": 7949,
          "sources": "/Users/louis/Downloads/submissions",
          "sections": [
            {
              "title": "Foundations",
              "papers": [7,11,14,18,20,24,35,46,63]
            },
            {
              "title": "Applications",
              "papers": [2,6,22,29,58,68]
            }
          ]
        }
    
4. Use `lncs inspect` to decompress any submissions packaged as ZIP files, and to locate compiled PDF files:

        > lncs inspect
        Inspecting paper 7 at submissions/ecmfa2013_submission_07/*
        Inspecting paper 11 submissions/ecmfa2013_submission_11/*
        ...
        Updating manifest.json
        
        > cat manifest.json
        {
          "volume_number": 7949,
          "sources": "/Users/louis/Downloads/submissions",
          "sections": [
            {
              "title": "Foundations",
              "papers": [7,11,14,18,20,24,35,46,63]
            },
            {
              "title": "Applications",
              "papers": [2,6,22,29,58,68]
            }
          ],
          "papers": {
            "7" : {
              "pdf": "7/paper.pdf"
            },
            "24" : {
              "pdf": ["ECMFA2013-cameraready.pdf", "figure1.pdf"]
              "FIXME": "Reduce the PDF key from an array to a single value which corresponds to the compiled PDF."
            }
          }
        }
        
5. Your manifest will now contain a `papers` key for each submission that is distributed as a ZIP file. Search for any "FIXME" keys that have been inserted by `lncs inspect` and correct any erroneous `pdf` key values. (Each submission should have a single value for the `pdf` key).
        
        > vi manifest.json
        # Deleted the line: "pdf": "figure1.pdf"
        > cat manifest.json
        {
          "volume_number": 7949,
          "sources": "/Users/louis/Downloads/submissions",
          "sections": [
            {
              "title": "Foundations",
              "papers": [7,11,14,18,20,24,35,46,63]
            },
            {
              "title": "Applications",
              "papers": [2,6,22,29,58,68]
            }
          ],
          "papers": {
            "7" : {
              "pdf": "7/paper.pdf"
            },
            "24" : {
              "pdf": "ECMFA2013-cameraready.pdf",
            }
          }
        }
        
    Note that the `pdf` key should contain the relative path to the PDF file in any submission packaged as a ZIP file.

6. Once your manifest has been finalised. All of the other `lncs` subcommand will work. Start by checking the status of the submissions:

        > lncs report
        Foundations
        007 -- 17pgs zip
        011 -- 17pgs zip
        014 -- 17pgs zip
        018 -- 16pgs zip
        020 -- 16pgs zip
        024 -- 16pgs zip
        035 -- 17pgs zip
        046 -- 16pgs zip
        063 -- 17pgs zip
        Applications
        002 -- 13pgs zip
        006 -- 13pgs zip
        022 -- 13pgs zip
        029 -- 13pgs zip
        058 -- 13pgs zip
        068 -- 11pgs zip

  If a submission exceeds your page limit, you may wish to contact the authors. If a submission is a PDF rather than a ZIP file, you may wish to do the same as you will need to send to Springer the LaTeX sources (and a signed copyright form).

7. Generate the set of directories required by Springer for the body of the proceedings:

        > lncs body
        > ls body
        79490001 79490020 79490054 79490086 79490119 79490152 79490178 79490204
        79490003 79490037 79490070 79490102 79490135 79490165 79490191 79490217
    
        > ls -R body/79490001
        7
    
        body/79490001/7:
        paper7.tex   paper7.pdf   copyright.pdf
    
8. Generate the title pages used to construct the table of contents and author index:

        > lncs titles
        > ls titles
        0001.tex  0020.tex  0054.tex  0086.tex  0119.tex  0152.tex  0178.tex  0204.tex  index.tex
        0003.tex  0037.tex  0070.tex  0102.tex  0135.tex  0165.tex  0191.tex  0217.tex
    
9. Run LaTeX to produce your PDF:

        > latex2pdf main.tex > main.pdf
        > open main.pdf
    
10. Inspect your PDF to ensure that all of the titles and names of authors are correct in the table of contents. Note that:

    * `lncs titles` works best for submissions that include LaTeX source files.
    * `lncs titles` extracts the contents of the \title and \author LaTeX tags verbatim. If an author has used non-standard or custom LaTeX commands in their \title and \author declarations, you may need to manually specify the title and authors of this submission in the `lncs` manifest (as described below).
    * `lncs titles` cannot extract title page information from MS Word or PDF files. You must manually specify the title and authors of submissions containing no LaTeX source in the `lncs` manifest (as described below).

You can override any titles or names of authors in the manifest file. For example:

        > cat manifest.json
        {
          "volume_number": 7949,
          "sources": "/Users/louis/Downloads/submissions",
          "sections": [
            {
              "title": "Foundations",
              "papers": [7,11,14,18,20,24,35,46,63]
            },
            {
              "title": "Applications",
              "papers": [2,6,22,29,58,68]
            }
          ],
          papers: {
            "7" : {
              "pdf": "7/paper.pdf",
              "title": "MOCQL: A Declarative Language for Ad-Hoc Model Querying",
              "authors": ["Harald St\\\"orrle"]
            },
            "20" : { 
              "title" : "Model-based Generation of Run-time Monitors for AUTOSAR",
              "authors" : ["Lars Patzina", "Sven Patzina", "Thorsten Piper", "Paul Manns"]
            },
            "24" : {
              "pdf": "ECMFA2013-cameraready.pdf"
            }
          }
        }
        
If a title or author must contain a LaTeX command, ensure that your JSON is properly escaped. For example, the LaTeX command `\"` becomes `\\\"` in the manifest as backslashes and quotes are escaped in JSON.

11. Regenerate your titles and PDF.

        > lncs titles
        > latex2pdf main.tex > main.pdf
        > open main.pdf


Contributing
------------
I'm afraid that this code is not well tested, factored or documented. It was quickly hacked together whilst in my first attempt to edit an LNCS volume. If I'm ever asked to edit a second volume, I plan to tidy up this gem and add a few more features. In the meantime, pull requests are very welcome.

Todo list:
* Better error reporting when the titles key is specified but not authors and vice versa

Acknowledgements
----------------
My thanks to Abel Gómez and Jordi Cabot for helping to improve LNCS, and for being courageous enough to be the first users of the tool other than myself!