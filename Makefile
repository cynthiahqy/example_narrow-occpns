all: run-scripts
	render-quarto

run-scripts: create-folder
	Rscript 01-carbon-from.R
	StataSE -b -e do 02-trace-do-file.do
	Rscript 03-extract-xmap-from-dta.R

render-quarto:
	quarto render stata-agg-xmap.qmd

create-folder:
	mkdir -p output
	mkdir -p interim

clean:
	rm -rf interim
	rm -f *.log

