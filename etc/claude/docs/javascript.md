# JavaScript

Read before writing JavaScript.

## Quotes

- Double quotes for textual information: messages, user input, labels.
- Single quotes for short strings that indicate a state, condition, or
  outcome (atom/enum-like values).

```js
const label = "Save changes"
const status = 'pending'
```

## Equality

Prefer `==` and `!=`. Use `===` / `!==` only where loose comparison genuinely
breaks due to JS coercion idiosyncrasies — and when you do, it's worth a
moment's thought about why.

## General

- Idiomatic, language-native patterns.
- Functional style when it improves clarity.
- Reuse existing implementations rather than rewriting.
