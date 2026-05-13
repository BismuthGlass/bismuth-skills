# Chat Completions

OpenRouter provides a unified, OpenAI-compatible API for hundreds of models.

- Base URL: `https://openrouter.ai/api/v1`
- Chat endpoint: `POST /api/v1/chat/completions`
- OpenAPI YAML: `https://openrouter.ai/openapi.yaml`
- OpenAPI JSON: `https://openrouter.ai/openapi.json`

## Authentication

All requests require a bearer token:

```http
Authorization: Bearer <OPENROUTER_API_KEY>
```

## Optional App Headers

```http
HTTP-Referer: https://yoursite.com
X-OpenRouter-Title: My App
X-OpenRouter-Categories: developer-tools
```

`HTTP-Referer` identifies the app on openrouter.ai. `X-OpenRouter-Title` or `X-Title` sets the displayed app title.

## Request Shape

```typescript
type Request = {
  messages?: Message[];
  prompt?: string;
  model?: string;
  response_format?: ResponseFormat;
  stop?: string | string[];
  stream?: boolean;
  plugins?: Plugin[];
  max_tokens?: number;
  temperature?: number;
  tools?: Tool[];
  tool_choice?: ToolChoice;
  parallel_tool_calls?: boolean;
  seed?: number;
  top_p?: number;
  top_k?: number;
  frequency_penalty?: number;
  presence_penalty?: number;
  repetition_penalty?: number;
  logit_bias?: { [key: number]: number };
  top_logprobs?: number;
  min_p?: number;
  top_a?: number;
  prediction?: { type: "content"; content: string };
  models?: string[];
  route?: "fallback";
  provider?: ProviderPreferences;
  user?: string;
};
```

Either `messages` or `prompt` is required. If `model` is omitted, the user's default model is used.

Use `models` plus `route: "fallback"` when the app should try multiple models. Use `provider` preferences only when the product needs explicit provider routing behavior.

## Messages

```typescript
type Message =
  | {
      role: "user" | "assistant" | "system";
      content: string | ContentPart[];
      name?: string;
    }
  | {
      role: "tool";
      content: string;
      tool_call_id: string;
      name?: string;
    };

type TextContent = { type: "text"; text: string };
type ImageContentPart = {
  type: "image_url";
  image_url: {
    url: string;
    detail?: string;
  };
};
type ContentPart = TextContent | ImageContentPart;
```

For non-OpenAI models, `name` may be prepended as `{name}: {content}`.

## Minimal Fetch Example

```typescript
const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
    "HTTP-Referer": "https://yoursite.com",
    "X-OpenRouter-Title": "My App",
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    model: "anthropic/claude-sonnet-4-5",
    messages: [{ role: "user", content: "What is the meaning of life?" }],
  }),
});

const data = await response.json();
console.log(data.choices[0].message.content);
```

## Response Shape

```typescript
type Response = {
  id: string;
  choices: NonStreamingChoice[];
  created: number;
  model: string;
  object: "chat.completion";
  system_fingerprint?: string;
  usage?: ResponseUsage;
};

type NonStreamingChoice = {
  finish_reason: string | null;
  native_finish_reason: string | null;
  message: {
    content: string | null;
    role: string;
    tool_calls?: ToolCall[];
  };
  error?: ErrorResponse;
};
```

OpenRouter normalizes `finish_reason` to `tool_calls`, `stop`, `length`, `content_filter`, or `error`.

## Error Format

```typescript
type ErrorResponse = {
  code: number;
  message: string;
  metadata?: Record<string, unknown>;
};
```

Common HTTP statuses:

| Status | Meaning |
| --- | --- |
| `400` | Bad Request: invalid parameters |
| `401` | Unauthorized: invalid API key |
| `402` | Payment Required: insufficient credits |
| `429` | Too Many Requests: rate limited |
| `502` | Bad Gateway: provider error |
| `503` | Service Unavailable: no available providers |

## Assistant Prefill

Append a final assistant message to guide continuation from a partial response:

```typescript
messages: [
  { role: "user", content: "What is the meaning of life?" },
  { role: "assistant", content: "My best guess is" },
];
```
