# Bismuth Skills
A series of skills for AI agents.
- Skills to help with learning
- API explanations
- Other stuff

Compatible with Claude Code & Codex.

## Installation

```
# Install all skills for Claude Code
make CLIENT=claude all

# Install all skills for Codex
make CLIENT=codex all

# Install only a few skills for Codex
make CLIENT=codex swe-training-lessons ...

# Install using symlinks instead of copying
make CLIENT=codex LINK=1 all
```
