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

mirror/pr.owl.gz:
	if [ $(MIR) = true ]; then curl -L $(URIBASE)/pr.owl.gz --create-dirs -o $@ --retry 4 --max-time 200; fi
.PRECIOUS: mirror/pr.owl.gz

# This goal is only for extracting the mappings. We take all PRO terms in the seed
# Then get their parents and children, and then run the mappings query.
mirror/pr-mapping-filtered.owl: mirror/pr.owl seed.txt
	$(ROBOT) filter -i $< -T seed.txt --select "self children parents" --trim false -o $@

# Extract cross-species mapping annotations to assert in PRO
human-pr-mapping.ttl: mirror/pr-mapping-filtered.owl
	$(ROBOT) query --format ttl --input $< --query sparql/human-pr-mapping.sparql $@
.PRECIOUS: human-pr-mapping.ttl

# Goal for any preprocessing needed on PRO before extract the module.
mirror/pr-pre.owl: mirror/pr.owl human-pr-mapping.ttl
	$(ROBOT) merge -i mirror/pr.owl -i human-pr-mapping.ttl -o $@

#build/%.db: src/scripts/prefixes.sql mirror/%.owl.gz | build/rdftab
#	rm -rf $@
#	sqlite3 $@ < $<
#	zcat < $(word 2,$^) | ./build/rdftab $@
#	sqlite3 $@ "CREATE INDEX idx_stanza ON statements (stanza);"
#	sqlite3 $@ "ANALYZE;"

pr_slim.owl: mirror/pr-pre.owl seed.txt
	$(ROBOT) extract -i $< -T seed.txt --force true --copy-ontology-annotations true --individuals include --method BOT \
		remove --term MOD:00693 \
		remove --select "<http://www.genenames.org/cgi-bin/gene_symbol_report*>" \
		query --update sparql/inject-subset-declaration.ru --update sparql/inject-synonymtype-declaration.ru --update sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) convert -f ofn --output $@.tmp.owl && mv $@.tmp.owl $@
.PRECIOUS: pr_slim.owl

pr_slim.obo: pr_slim.owl
	$(ROBOT) convert --input $< --check false -f obo -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo
.PRECIOUS: pr_slim.obo.obo

all: pr_slim.owl pr_slim.obo

