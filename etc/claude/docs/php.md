# PHP

Read before writing PHP.

## Quotes

- Double quotes for textual information: messages, user input, labels.
- Single quotes for short strings that indicate a state, condition, or
  outcome (atom/enum-like values).

```php
$label = "Save changes";
$status = 'pending';
```

Note: in PHP double quotes also enable interpolation, which lines up with
using them for textual/message strings.

## Equality

Prefer `==` and `!=`. Use `===` / `!==` only where loose comparison genuinely
breaks due to PHP's type-juggling — and when you do, know why you're reaching
for it.

## General

- Idiomatic, language-native patterns.
- Functional style when it improves clarity.
- Reuse existing implementations rather than rewriting.
