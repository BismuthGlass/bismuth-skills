---
name: openrouter-api
description: Use when building, debugging, or reviewing code that calls the OpenRouter API, including chat completions, streaming, tool calling, structured outputs, routing, usage, costs, and API error handling.
metadata:
  short-description: Build against the OpenRouter API
---

# OpenRouter Development

Use this skill when the user is implementing or debugging OpenRouter API integrations.
Prefer the project's existing HTTP client, SDK, environment-variable, retry, and logging patterns before adding new abstractions.

## Core Workflow

1. Identify the API surface: basic chat generation, streaming, tool calling, structured JSON, usage/cost tracking, or error handling.
2. Read only the relevant reference file below.
3. Confirm the code sends `Authorization: Bearer <OPENROUTER_API_KEY>` and uses `https://openrouter.ai/api/v1`.
4. Preserve OpenAI-compatible request shapes where possible, then add OpenRouter-specific fields only when needed.
5. Validate response parsing for the chosen mode: non-streaming responses use `message`; streaming responses use `delta`.

## References

- [references/chat-completions.md](references/chat-completions.md): authentication, base URL, optional app headers, request body, messages, model routing, responses, standard errors, and assistant prefill.
- [references/streaming.md](references/streaming.md): SSE streaming, final usage chunk, keep-alive comments, cancellation, and pre-token vs mid-stream errors.
- [references/tool-calling.md](references/tool-calling.md): function tool schemas, the three-step tool-call exchange, tool choice, parallel calls, streaming tools, and agent loops.
- [references/outputs-usage.md](references/outputs-usage.md): structured outputs, usage/cost data, and `/generation` lookup.

## Implementation Notes

- For model selection and capability checks, prefer OpenRouter model identifiers such as `anthropic/claude-sonnet-4-5` and verify feature support when a request uses `tools`, images, or provider-specific sampling fields.
- Include optional `HTTP-Referer` and `X-OpenRouter-Title` headers for user-facing apps when the project has a stable site/app identity.
- Do not assume every provider supports every sampling parameter. Keep advanced parameters opt-in and close to the call site or model configuration.
- For streaming code, ignore SSE comment lines and handle both thrown request errors and in-stream error chunks.
- For tool calling, always send the `tools` definitions again when returning tool results so OpenRouter can validate the schema on each request.
