SRC_DIR      := $(dir $(firstword $(MAKEFILE_LIST)))
LESSON_MD    := $(SRC_DIR)LESSON.md

PANDOC       := pandoc
PANDOC_FLAGS := --standalone --toc --toc-depth=2 --css=course.css

.PHONY: all html clean

all: html

html: $(LESSON_MD)
	$(PANDOC) $(PANDOC_FLAGS) -o index.html $(LESSON_MD)
	cp $(SRC_DIR)course.css .
	if [ -d "$(SRC_DIR)code" ]; then cp -r "$(SRC_DIR)code" .; else mkdir -p code; fi

clean:
	rm -f index.html course.css
	rm -rf code
