# Tool Calling

Tool calls let the model request execution of external functions. The model does not run tools itself. The application executes the requested function and returns the result.

OpenRouter normalizes tool calling across supported models and providers. To find compatible models, filter models by `supported_parameters=tools`.

## Types

```typescript
type Tool = {
  type: "function";
  function: FunctionDescription;
};

type FunctionDescription = {
  name: string;
  description?: string;
  parameters: object;
};

type ToolChoice =
  | "none"
  | "auto"
  | { type: "function"; function: { name: string } };

type ToolCall = {
  id: string;
  type: "function";
  function: {
    name: string;
    arguments: string;
  };
};
```

`function.arguments` is a JSON-encoded string. Parse and validate it before execution.

## Three-Step Pattern

Step 1: send messages plus tool definitions.

```json
{
  "model": "anthropic/claude-sonnet-4-5",
  "messages": [{ "role": "user", "content": "What are some James Joyce books?" }],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "search_gutenberg_books",
        "description": "Search for books in the Project Gutenberg library",
        "parameters": {
          "type": "object",
          "properties": {
            "search_terms": {
              "type": "array",
              "items": { "type": "string" }
            }
          },
          "required": ["search_terms"]
        }
      }
    }
  ]
}
```

The model responds with `finish_reason: "tool_calls"` and a `message.tool_calls` array.

Step 2: execute tools client-side.

```typescript
const toolCalls = response.choices[0].message.tool_calls ?? [];
const toolResults = await Promise.all(
  toolCalls.map((tc) => {
    const args = JSON.parse(tc.function.arguments);
    return myToolMap[tc.function.name](args);
  }),
);
```

Step 3: send assistant tool calls and tool results back to get the final answer.

```json
{
  "model": "anthropic/claude-sonnet-4-5",
  "messages": [
    { "role": "user", "content": "What are some James Joyce books?" },
    {
      "role": "assistant",
      "content": null,
      "tool_calls": [
        {
          "id": "call_abc123",
          "type": "function",
          "function": {
            "name": "search_gutenberg_books",
            "arguments": "{\"search_terms\":[\"James\",\"Joyce\"]}"
          }
        }
      ]
    },
    {
      "role": "tool",
      "tool_call_id": "call_abc123",
      "content": "[{\"title\":\"Ulysses\"},{\"title\":\"Dubliners\"}]"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "search_gutenberg_books",
        "description": "Search for books in the Project Gutenberg library",
        "parameters": {
          "type": "object",
          "properties": {
            "search_terms": {
              "type": "array",
              "items": { "type": "string" }
            }
          },
          "required": ["search_terms"]
        }
      }
    }
  ]
}
```

Keep the same tool definitions in every request, including the follow-up request with tool results.

## Tool Choice

```json
{ "tool_choice": "auto" }
```

```json
{ "tool_choice": "none" }
```

```json
{ "tool_choice": { "type": "function", "function": { "name": "search_database" } } }
```

## Parallel Tool Calls

Most models may request multiple tools in one turn. Disable this when the application requires sequential execution:

```json
{ "parallel_tool_calls": false }
```

## Streaming Tool Calls

With `stream: true`, tool call deltas arrive incrementally on `delta.tool_calls`. Accumulate deltas and wait for `finish_reason: "tool_calls"` before executing.

```typescript
const reader = response.body.getReader();
const toolCalls = [];

while (true) {
  const { done, value } = await reader.read();
  if (done) break;

  const lines = new TextDecoder().decode(value).split("\n").filter(Boolean);
  for (const line of lines) {
    if (!line.startsWith("data: ")) continue;
    const data = JSON.parse(line.slice(6));
    const choice = data.choices?.[0];

    if (choice?.delta?.tool_calls) toolCalls.push(...choice.delta.tool_calls);
    if (choice?.finish_reason === "tool_calls") await handleToolCalls(toolCalls);
  }
}
```

## Agent Loop

For agents that may need repeated tool calls, cap iterations and append every assistant/tool message to the conversation:

```typescript
const MAX_ITERATIONS = 10;

for (let i = 0; i < MAX_ITERATIONS; i++) {
  const result = await openRouter.chat.send({ model, tools, messages });
  const msg = result.choices[0].message;
  messages.push(msg);

  if (!msg.tool_calls?.length) break;

  for (const toolCall of msg.tool_calls) {
    const args = JSON.parse(toolCall.function.arguments);
    const toolResult = await myToolMap[toolCall.function.name](args);
    messages.push({
      role: "tool",
      tool_call_id: toolCall.id,
      content: JSON.stringify(toolResult),
    });
  }
}
```

## Function Schema Guidance

Use descriptive function names, clear descriptions, JSON Schema parameters, and enums for closed option sets. Keep descriptions focused on when the model should call the tool and what each argument means.
