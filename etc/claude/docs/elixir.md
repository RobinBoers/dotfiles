# Elixir

Elixir (with standalone Plug or Phoenix) is the default assumption when no
language is specified.

Write like you're José Valim.

## Anti-patterns to avoid

### Complex `else` clauses in `with`

This anti-pattern refers to `with` expressions that flatten all its error clauses into a single complex `else` block. This situation is harmful to the code readability and maintainability because it's difficult to know from which clause the error value came.

    def open_decoded_file(path) do
      with {:ok, encoded} <- File.read(path),
          {:ok, decoded} <- Base.decode64(encoded) do
        {:ok, String.trim(decoded)}
      else
        {:error, _} -> {:error, :badfile}
        :error -> {:error, :badencoding}
      end
    end

In the code above, it is unclear how each pattern on the left side of <- relates to their error at the end. The more patterns in a with, the less clear the code gets, and the more likely it is that unrelated failures will overlap each other.

### Alternative return types

This anti-pattern refers to functions that receive options (typically as a keyword list parameter) that drastically change their return type. Because options are optional and sometimes set dynamically, if they also change the return type, it may be hard to understand what the function actually returns.

    defmodule AlternativeInteger do
      @spec parse(String.t(), keyword()) :: integer() | {integer(), String.t()} | :error
      def parse(string, options \\ []) when is_list(options) do
        if Keyword.get(options, :discard_rest, false) do
          case Integer.parse(string) do
            {int, _rest} -> int
            :error -> :error
          end
        else
          Integer.parse(string)
        end
      end
    end

To refactor this anti-pattern, as shown next, add a specific function for each return type (for example, parse_discard_rest/1), no longer delegating this to options passed as arguments.

    defmodule AlternativeInteger do
      @spec parse(String.t()) :: {integer(), String.t()} | :error
      def parse(string) do
        Integer.parse(string)
      end

      @spec parse_discard_rest(String.t()) :: integer() | :error
      def parse_discard_rest(string) do
        case Integer.parse(string) do
          {int, _rest} -> int
          :error -> :error
        end
      end
    end

### Boolean obsession

This anti-pattern happens when booleans are used instead of atoms to encode information. The usage of booleans themselves is not an anti-pattern, but whenever multiple booleans are used with overlapping states, replacing the booleans by atoms (or composite data types such as tuples) may lead to clearer code.

    defmodule MyApp do
      def process(invoice, options \\ []) do
        cond do
          options[:admin] ->  # Is an admin
          options[:editor] -> # Is an editor
          true ->          # Is none
        end
      end
    end

Instead of using multiple options, the code above could be refactored to receive a single option, called :role, that can be either :admin, :editor, or :default:

    defmodule MyApp do
      def process(invoice, options \\ []) do
        case Keyword.get(options, :role, :default) do
          :admin ->   # Is an admin
          :editor ->  # Is an editor
          :default -> # Is none
        end
      end
    end

### Unrelated multi-clause function

Using multi-clause functions is a powerful Elixir feature. However, some developers may abuse this feature to group unrelated functionality, which is an anti-pattern.

A frequent example of this usage of multi-clause functions occurs when developers mix unrelated business logic into the same function definition, in a way that the behavior of each clause becomes completely distinct from the others. Such functions often have too broad specifications, making it difficult for other developers to understand and maintain them.

    @doc """
    Updates a struct.

    If given a product, it will...

    If given an animal, it will...
    """
    def update(%Product{count: count, material: material})  do
      # ...
    end

    def update(%Animal{count: count, skin: skin})  do
      # ...
    end

As shown below, a possible solution to this anti-pattern is to break the business rules that are mixed up in a single unrelated multi-clause function in simple functions. Each function can have a specific name and @doc, describing its behavior and parameters received. While this refactoring sounds simple, it can impact the function's callers, so be careful!

    @doc """
    Updates a product.

    It will...
    """
    def update_product(%Product{count: count, material: material}) do
      # ...
    end

    @doc """
    Updates an animal.

    It will...
    """
    def update_animal(%Animal{count: count, skin: skin}) do
      # ...
    end
