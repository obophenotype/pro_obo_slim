TODAY ?=                    $(shell date +%Y-%m-%d)
URIBASE=                    http://purl.obolibrary.org/obo
ONTBASE=                    $(URIBASE)/pr/obophenotype
ROBOT=                      robot
VERSION=                    $(TODAY)
ANNOTATE_ONTOLOGY_VERSION = annotate -V $(ONTBASE)/releases/$(VERSION)/$@ --annotation owl:versionInfo $(VERSION)

MIR=                        true

mirror/pr.owl:
	if [ $(MIR) = true ]; then curl -L $(URIBASE)/pr.owl.gz --create-dirs -o mirror/pr.owl.gz --retry 4 --max-time 200 && $(ROBOT) convert -i mirror/pr.owl.gz -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/pr.owl

pr_slim.owl: mirror/pr.owl seed.txt
	$(ROBOT) extract -i $< -T seed.txt --force true --copy-ontology-annotations true --individuals include --method BOT \
		query --update sparql/inject-subset-declaration.ru --update sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) convert -f ofn --output $@.tmp.owl && mv $@.tmp.owl $@
.PRECIOUS: pr_slim.owl

pr_slim.obo: pr_slim.owl
	$(ROBOT) convert --input $< --check false -f obo -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo
.PRECIOUS: pr_slim.obo.obo

all: pr_slim.owl pr_slim.obo