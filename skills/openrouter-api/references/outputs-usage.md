# Outputs and Usage

## Structured Outputs

Use `response_format` to enforce JSON output.

Basic JSON mode:

```json
{ "response_format": { "type": "json_object" } }
```

Strict JSON Schema mode:

```json
{
  "response_format": {
    "type": "json_schema",
    "json_schema": {
      "name": "UserProfile",
      "strict": true,
      "schema": {
        "type": "object",
        "properties": {
          "name": { "type": "string" },
          "age": { "type": "integer" }
        },
        "required": ["name", "age"]
      }
    }
  }
}
```

When using strict schemas, keep schemas small, explicit, and compatible with the selected model.

## Inline Usage

Non-streaming responses include usage under `usage`:

```typescript
type ResponseUsage = {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
  prompt_tokens_details?: {
    cached_tokens: number;
    cache_write_tokens?: number;
    audio_tokens?: number;
    video_tokens?: number;
  };
  completion_tokens_details?: {
    reasoning_tokens?: number;
    audio_tokens?: number;
    image_tokens?: number;
  };
  cost?: number;
  is_byok?: boolean;
  cost_details?: {
    upstream_inference_cost?: number;
    upstream_inference_prompt_cost: number;
    upstream_inference_completions_cost: number;
  };
  server_tool_use?: {
    web_search_requests?: number;
  };
};
```

Streaming responses include usage in the final chunk only:

```typescript
for await (const chunk of stream) {
  if (chunk.usage) {
    console.log("Prompt tokens:", chunk.usage.prompt_tokens);
    console.log("Completion tokens:", chunk.usage.completion_tokens);
    console.log("Total cost:", chunk.usage.cost);
  }
}
```

Token counts use each model's native tokenizer, so counts and costs can vary between models for the same prompt.

## Generation Lookup

Every completion includes an `id`, such as `gen-xxxxxxxxxxxxxx`. Use it to fetch full generation stats later:

```typescript
const statsResponse = await fetch(
  `https://openrouter.ai/api/v1/generation?id=${completionResponse.id}`,
  {
    headers: { Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}` },
  },
);

const stats = await statsResponse.json();
```

The `/api/v1/generation` endpoint returns token counts, cost, selected model, provider, and timestamps.
