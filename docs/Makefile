

TIMING2SVG = ../../docs/tools/timing/timing.py
SVG2PDF = ../../docs/tools/svg2boundedPDF.py
MEMMAP = latex/memmap.py
LATEX = pdflatex


TIMINGFILES := $(patsubst %.timing,%.timing.pdf,$(wildcard *.timing))
MEMMAPFILES := $(patsubst %.memmap,%.memmap.tex,$(wildcard *.memmap))

TEXFILES := $(wildcard *.tex)



%.timing.pdf : %.timing
	$(TIMING2SVG) $<
	$(SVG2PDF) $<.svg	 

%.memmap.tex : %.memmap
	$(MEMMAP) $< > $@

%.pdf : %.tex
	$(LATEX) $< 

all: buses.pdf

DSPboard.pdf: DSPboard.tex  $(TIMINGFILES) $(MEMMAPFILES)


clean:
	rm -Rf *.timing.pdf *.timing.svg
	rm -Rf $(patsubst %.tex,%.pdf,$(TEXFILES))
	rm -Rf *.log *.aux *.dvi 
