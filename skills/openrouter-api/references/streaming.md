# Streaming

Set `stream: true` to receive Server-Sent Events for any model.

## Streaming Shape

Streaming chunks use `delta` instead of `message`:

```typescript
type StreamingChoice = {
  finish_reason: string | null;
  native_finish_reason: string | null;
  delta: {
    content: string | null;
    role?: string;
    tool_calls?: ToolCall[];
  };
  error?: ErrorResponse;
};
```

Usage data appears once in the final chunk with an empty `choices` array, immediately before `data: [DONE]`.

## SDK Example

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({ apiKey: process.env.OPENROUTER_API_KEY });

const stream = await openRouter.chat.send({
  model: "anthropic/claude-sonnet-4-5",
  messages: [{ role: "user", content: "Write a short story." }],
  stream: true,
});

for await (const chunk of stream) {
  const content = chunk.choices?.[0]?.delta?.content;
  if (content) process.stdout.write(content);

  if (chunk.usage) console.log("\nUsage:", chunk.usage);
}
```

## SSE Keep-Alive Comments

OpenRouter may send valid SSE comments:

```text
: OPENROUTER PROCESSING
```

Ignore comment lines while parsing. They can be used as a signal for loading UI, but they are not model output. `eventsource-parser`, the OpenAI SDK, and the Vercel AI SDK handle this pattern correctly.

## Cancellation

Pass an `AbortController` signal. For supported providers, aborting a streaming request stops model processing and billing.

```typescript
const controller = new AbortController();

const stream = await openRouter.chat.send(
  { model: "anthropic/claude-sonnet-4-5", messages, stream: true },
  { signal: controller.signal },
);

controller.abort();
```

Cancellation is only effective for streaming requests on supported providers. Non-streaming calls or unsupported providers may continue processing and billing.

## Error Handling

Before any tokens are sent, errors are normal JSON responses with an HTTP status code:

```json
{
  "error": {
    "code": 401,
    "message": "Invalid API key"
  }
}
```

After tokens have started, the HTTP response is already `200 OK`, so the error arrives as an SSE event with `finish_reason: "error"`:

```json
{
  "id": "cmpl-abc123",
  "object": "chat.completion.chunk",
  "error": { "code": "server_error", "message": "Provider disconnected unexpectedly" },
  "choices": [{ "index": 0, "delta": { "content": "" }, "finish_reason": "error" }]
}
```

Robust clients handle both cases:

```typescript
async function streamWithErrorHandling(prompt: string) {
  try {
    const stream = await openRouter.chat.send({
      model: "anthropic/claude-sonnet-4-5",
      messages: [{ role: "user", content: prompt }],
      stream: true,
    });

    for await (const chunk of stream) {
      if ("error" in chunk) {
        console.error("Stream error:", chunk.error.message);
        return;
      }

      const content = chunk.choices?.[0]?.delta?.content;
      if (content) process.stdout.write(content);
    }
  } catch (error) {
    console.error("Request error:", error);
  }
}
```
