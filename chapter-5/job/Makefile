.PHONY: run-template
run-template:
	mkdir -p jobs
	for i in apple banana cherry \
	do                           \
	  cat job-tmpl.yaml | sed -e "s/\$ITEM/$i/" > ./jobs/job-$i.yaml \
	done \