SHELL := /bin/sh

SKILLS_DIR := skills
SKILLS := $(notdir $(wildcard $(SKILLS_DIR)/*))

CLIENT ?=
LINK ?= 0

DEST_ROOT_codex := $(HOME)/.codex/skills
DEST_ROOT_claude := $(HOME)/.claude/skills
DEST_ROOT := $(DEST_ROOT_$(CLIENT))

.PHONY: all list check-client $(SKILLS)

all: check-client $(SKILLS)

list:
	@printf '%s\n' $(SKILLS)

check-client:
ifndef CLIENT
	$(error CLIENT is required. Use CLIENT=codex or CLIENT=claude)
endif
ifeq ($(CLIENT),)
	$(error CLIENT is required. Use CLIENT=codex or CLIENT=claude)
endif
ifeq ($(filter $(CLIENT),codex claude),)
	$(error Unsupported CLIENT '$(CLIENT)'. Use CLIENT=codex or CLIENT=claude)
endif

$(SKILLS): check-client
	@mkdir -p "$(DEST_ROOT)"
	@rm -rf "$(DEST_ROOT)/$@"
	@if [ "$(LINK)" = "1" ]; then \
		ln -s "$(CURDIR)/$(SKILLS_DIR)/$@" "$(DEST_ROOT)/$@"; \
		printf 'Linked %s -> %s/%s\n' "$@" "$(DEST_ROOT)" "$@"; \
	else \
		cp -R "$(SKILLS_DIR)/$@" "$(DEST_ROOT)/$@"; \
		printf 'Installed %s -> %s/%s\n' "$@" "$(DEST_ROOT)" "$@"; \
	fi
