LNCS Volume Editor Tools
========================
A small set of tools that automate some of the more tedious parts of preparing an LNCS volume.

The conventions enforced by `lncs` are intended to comply with the LNCS guidelines for volume editors. If you find an inconsistency between `lncs` and the LNCS guidelines, please [file a bug report](https://github.com/louismrose/lncs/issues).

Installation
------------

    gem install lncs
    lncs help

Recommended workflow
--------------------

1. Download the submissions for your volume

2. Setup a working directory

    \> mkdir ecmfa2013
    \> cd ecmfa2013
    \> lncs init    

3. Customise the manifest (e.g., set the path to the submissions, the volume number, ...)

    \> vi manifest.json
    \> cat manifest.json
    {
      "volume_number": 7949,
      "sources": "/Users/louis/Downloads/submissions",
      "sections": [
        {
          title: "Foundations",
          papers: [7,11,14,18,20,24,35,46,63]
        },
        {
          title: "Applications",
          papers: [2,6,22,29,58,68]
        }
      ]
    }
    
4. Unpack and inspect all of the submissions

    \> lncs inspect
    \> cd submissions
    \> ls -R
    
    ./ecmfa2013_submission_07:
    7
    ./ecmfa2013_submission_07/7:
    paper7.tex   paper7.pdf   copyright.pdf
    
    ./ecmfa2013_submission_24:
    ECMFA2013-cameraready.pdf   ECMFA2013-cameraready.docx  copyright.pdf


5. Update the manifest with the paths to the PDF files of each paper

    \> vi manifest.json
    \> cat manifest.json
    {
      "volume_number": 7949,
      "sources": "/Users/louis/Downloads/submissions",
      "sections": [
        {
          title: "Foundations",
          papers: [7,11,14,18,20,24,35,46,63]
        },
        {
          title: "Applications",
          papers: [2,6,22,29,58,68]
        }
      ],
      papers: {
        "7" : {
          pdf: "7/paper.pdf"
        },
        "24" : {
          pdf: "ECMFA2013-cameraready.pdf"
        }
      }
    }

6. Check the status of the submissions 

    \> lncs report
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

  If a submission exceeds your page limit, you may wish to contact the authors. If a submission is a PDF rather than a ZIP file, you may wish to do the same as you will need to send to Springer the sources and a signed copyright form for each submission.

7. Generate the set of directories required by Springer for the body of the proceedings

    \> lncs body
    \> ls body
    79490001 79490020 79490054 79490086 79490119 79490152 79490178 79490204
    79490003 79490037 79490070 79490102 79490135 79490165 79490191 79490217
    
    \> ls -R body/79490001
    7
    
    body/79490001/7:
    paper7.tex   paper7.pdf   copyright.pdf
    
8. Generate the title pages used to construct the table of contents and author index

    \> lncs titles
    \> ls titles
    0001.tex  0020.tex  0054.tex  0086.tex  0119.tex  0152.tex  0178.tex  0204.tex  index.tex
    0003.tex  0037.tex  0070.tex  0102.tex  0135.tex  0165.tex  0191.tex  0217.tex
    
9. Run LaTeX to produce your PDF

    \> latex2pdf main.tex
    \> open main.pdf
    
10. Override any titles or names of authors (because, for example, `lncs` cannot extract title page information from MS Word source files).

    \> vi manifest.json
    \> cat manifest.json
    {
      "volume_number": 7949,
      "sources": "/Users/louis/Downloads/submissions",
      "sections": [
        {
          title: "Foundations",
          papers: [7,11,14,18,20,24,35,46,63]
        },
        {
          title: "Applications",
          papers: [2,6,22,29,58,68]
        }
      ],
      papers: {
        "7" : {
          pdf: "7/paper.pdf",
          title: "MOCQL: A Declarative Language for Ad-Hoc Model Querying",
          authors: ["Harald St\\\"orrle"]
        },
        "24" : {
          pdf: "ECMFA2013-cameraready.pdf"
        }
      }
    }

11. Regenerate your titles and PDF.

    \> lncs titles
    \> latex2pdf main.tex
    \> open main.pdf


Contributing
------------
I'm afraid that this code is not well tested, factored or documented (yet). It was quickly hacked together whilst in my first attempt to edit an LNCS volume. If I'm ever asked to edit a second volume, I plan to tidy up this gem and add a few more features. In the meantime, psull requests are welcome.

Todo list:
* Port to Thor actions
* How to depend on other gems from within this gem?
* Test loading classes without the executable (i.e. require "lncs" from irb)
* Pick a license, add to repo and update gemspec
* Better error reporting when the papers pdf key is incorrect (and a fiel doesn't exist)
* Test on ruby 1.8