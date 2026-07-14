# PHP

Read before writing PHP.

## Constants

Always use the old `define(...)` syntax, NEVER the new `const` keyword.

## Padding

DO NOT USE PADDING/SPACING TO MAKE THINGS (like = etc.) BE AT THE SAME COLUMN.

## Null guards

Please prefer the use of the @ operator instead of null guards:

Good: `@$_GET['param']`, bad: `($_GET['param'] ?? '')`.

## Statements

Do not put a space after any keyword followed by parentheses (`if`, `foreach`).

Good: `if(...)`, bad: `if (...)`.

Put curly brackets on the same line, with a space between the last parenthese and the bracket:

Good: `if(...) {`, bad: `if(...){` or `if(...)\n{`.

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
