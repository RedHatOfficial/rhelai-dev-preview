#
# If you want to see the full commands, run:
#   NOISY_BUILD=y make
#
ifeq ($(NOISY_BUILD),)
    ECHO_PREFIX=@
    CMD_PREFIX=@
    PIPE_DEV_NULL=> /dev/null 2> /dev/null
else
    ECHO_PREFIX=@\#
    CMD_PREFIX=
    PIPE_DEV_NULL=
endif

.PHONY: help
help:
	$(CMD_PREFIX) make -C training $@

.PHONY: md-lint
md-lint: ## Lint markdown files
	$(ECHO_PREFIX) printf "  %-12s ./...\n" "[MD LINT]"
	$(CMD_PREFIX) podman run --rm -v $(CURDIR):/workdir --security-opt label=disable docker.io/davidanson/markdownlint-cli2:v0.6.0 > /dev/null

AI_LAB_REPO:=https://github.com/containers/ai-lab-recipes.git
AI_LAB_REF:=ef4ae1848bce16277eb460c451d4a89cfa08469a
.PHONY: update-training-dir
update-training-dir: ## Update the contents of the training directory
	$(ECHO_PREFIX) printf "  %-12s $(AI_LAB_RECIPES_REF)\n" "[UPDATE TRAINING DIR]"
	$(CMD_PREFIX) [ ! -d ai-lab-recipes ] || rm -rf ai-lab-recipes
	$(CMD_PREFIX) git clone ${AI_LAB_REPO} ai-lab-recipes
	$(CMD_PREFIX) git rm -r training
	$(CMD_PREFIX) [ ! -d training ] || mkdir -p training
	$(CMD_PREFIX) cd ai-lab-recipes && git archive $(AI_LAB_REF) training | tar -x -C ../
	$(CMD_PREFIX) rm -rf ai-lab-recipes
	$(CMD_PREFIX) git add training

.PHONY: spellcheck
spellcheck:
	$(CMD_PREFIX) python -m pyspelling --config .spellcheck.yml --spellchecker aspell

.PHONY: spellcheck-sort
spellcheck-sort: .spellcheck-en-custom.txt
	$(CMD_PREFIX) sort -d -f -o $< $<

# Catch-all target to pass through any other target to the training directory
%:
	$(CMD_PREFIX) make -C training $@
