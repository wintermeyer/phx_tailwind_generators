defmodule Mix.Tasks.Phx.Gen.Tailwind do
  @shortdoc "Generates controller, views, and context for an HTML resource with Tailwind CSS"

  @moduledoc """
  Generates controller, views, and context for an HTML resource with
  Tailwind CSS.

      mix phx.gen.tailwind Accounts User users name:string age:integer

  The first argument is the context module followed by the schema module
  and its plural name (used as the schema table name).

  The context is an Elixir module that serves as an API boundary for
  the given resource. A context often holds many related resources.
  Therefore, if the context already exists, it will be augmented with
  functions for the given resource.

  > Note: A resource may also be split
  > over distinct contexts (such as `Accounts.User` and `Payments.User`).

  The schema is responsible for mapping the database fields into an
  Elixir struct. It is followed by an optional list of attributes,
  with their respective names and types. See `mix tailwind.gen.schema`
  for more information on attributes.

  Overall, this generator will add the following files to `lib/`:

    * a context module in `lib/app/accounts.ex` for the accounts API
    * a schema in `lib/app/accounts/user.ex`, with an `users` table
    * a view in `lib/app_web/views/user_view.ex`
    * a controller in `lib/app_web/controllers/user_controller.ex`
    * default CRUD templates in `lib/app_web/templates/user`

  ## The context app

  A migration file for the repository and test files for the context and
  controller features will also be generated.

  The location of the web files (controllers, views, templates, etc) in an
  umbrella application will vary based on the `:context_app` config located
  in your applications `:generators` configuration. When set, the Phoenix
  generators will generate web files directly in your lib and test folders
  since the application is assumed to be isolated to web specific functionality.
  If `:context_app` is not set, the generators will place web related lib
  and test files in a `web/` directory since the application is assumed
  to be handling both web and domain specific functionality.
  Example configuration:

      config :my_app_web, :generators, context_app: :my_app

  Alternatively, the `--context-app` option may be supplied to the generator:

      mix phx.gen.tailwind Sales User users --context-app warehouse

  ## Web namespace

  By default, the controller and view will be namespaced by the schema name.
  You can customize the web module namespace by passing the `--web` flag with a
  module name, for example:

      mix phx.gen.tailwind Sales User users --web Sales

  Which would generate a `lib/app_web/controllers/sales/user_controller.ex` and
  `lib/app_web/views/sales/user_view.ex`.

  ## Customising the context, schema, tables and migrations

  In some cases, you may wish to bootstrap HTML templates, controllers,
  and controller tests, but leave internal implementation of the context
  or schema to yourself. You can use the `--no-context` and `--no-schema`
  flags for file generation control.

  You can also change the table name or configure the migrations to
  use binary ids for primary keys, see `mix tailwind.gen.schema` for more
  information.
  """
  use Mix.Task

  alias Mix.Phoenix.{Context, Schema}
  alias Mix.Tasks.Phx.Gen

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise "mix phx.gen.tailwind must be invoked from within your *_web application root directory"
    end

    {context, schema} = Gen.Context.build(args)
    Gen.Context.prompt_for_code_injection(context)

    binding = [context: context, schema: schema, inputs: inputs(schema)]
    paths = [:phx_tailwind_generators, :phoenix]

    prompt_for_conflicts(context)

    context
    |> copy_new_files(paths, binding)
    |> inject_error_helper(paths, binding)
    |> print_shell_instructions()
  end

  defp prompt_for_conflicts(context) do
    context
    |> files_to_be_generated()
    |> Kernel.++(context_files(context))
    |> Mix.Phoenix.prompt_for_conflicts()
  end
  defp context_files(%Context{generate?: true} = context) do
    Gen.Context.files_to_be_generated(context)
  end
  defp context_files(%Context{generate?: false}) do
    []
  end

  @doc false
  def files_to_be_generated(%Context{schema: schema, context_app: context_app}) do
    web_prefix = Mix.Phoenix.web_path(context_app)
    test_prefix = Mix.Phoenix.web_test_path(context_app)
    web_path = to_string(schema.web_path)

    [
      {:eex, "controller.ex",       Path.join([web_prefix, "controllers", web_path, "#{schema.singular}_controller.ex"])},
      {:eex, "edit.html.eex",       Path.join([web_prefix, "templates", web_path, schema.singular, "edit.html.eex"])},
      {:eex, "form.html.eex",       Path.join([web_prefix, "templates", web_path, schema.singular, "form.html.eex"])},
      {:eex, "index.html.eex",      Path.join([web_prefix, "templates", web_path, schema.singular, "index.html.eex"])},
      {:eex, "new.html.eex",        Path.join([web_prefix, "templates", web_path, schema.singular, "new.html.eex"])},
      {:eex, "show.html.eex",       Path.join([web_prefix, "templates", web_path, schema.singular, "show.html.eex"])},
      {:eex, "view.ex",             Path.join([web_prefix, "views", web_path, "#{schema.singular}_view.ex"])},
      {:eex, "controller_test.exs", Path.join([test_prefix, "controllers", web_path, "#{schema.singular}_controller_test.exs"])},
    ]
  end

  @doc false
  def copy_new_files(%Context{} = context, paths, binding) do
    files = files_to_be_generated(context)
    Mix.Phoenix.copy_from(paths, "priv/templates/phx.gen.tailwind", binding, files)
    if context.generate?, do: Gen.Context.copy_new_files(context, paths, binding)
    context
  end

  @doc false
  def print_shell_instructions(%Context{schema: schema, context_app: ctx_app} = context) do
    if schema.web_namespace do
      Mix.shell().info """

      Add the resource to your #{schema.web_namespace} :browser scope in #{Mix.Phoenix.web_path(ctx_app)}/router.ex:

          scope "/#{schema.web_path}", #{inspect Module.concat(context.web_module, schema.web_namespace)}, as: :#{schema.web_path} do
            pipe_through :browser
            ...
            resources "/#{schema.plural}", #{inspect schema.alias}Controller
          end
      """
    else
      Mix.shell().info """

      Add the resource to your browser scope in #{Mix.Phoenix.web_path(ctx_app)}/router.ex:

          resources "/#{schema.plural}", #{inspect schema.alias}Controller
      """
    end
    if context.generate?, do: Gen.Context.print_shell_instructions(context)
  end

  @doc false
  def inputs(%Schema{} = schema) do
    Enum.map(schema.attrs, fn
      {_, {:references, _}} ->
        {nil, nil, nil}
      {key, :integer} ->
        {label(key), ~s(<%= number_input f, #{inspect(key)}, class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, :float} ->
        {label(key), ~s(<%= number_input f, #{inspect(key)}, step: "any", class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, :decimal} ->
        {label(key), ~s(<%= number_input f, #{inspect(key)}, step: "any", class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, :boolean} ->
        {label(key), ~s(<%= checkbox f, #{inspect(key)}, class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, :text} ->
        {label(key), ~s(<%= textarea f, #{inspect(key)}, class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, :date} ->
        {label(key), ~s(<%= date_select f, #{inspect(key)}, class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, :time} ->
        {label(key), ~s(<%= time_select f, #{inspect(key)}, class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, :utc_datetime} ->
        {label(key), ~s(<%= datetime_select f, #{inspect(key)}, class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, :naive_datetime} ->
        {label(key), ~s(<%= datetime_select f, #{inspect(key)}, class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, {:array, :integer}} ->
        {label(key), ~s(<%= multiple_select f, #{inspect(key)}, ["1": 1, "2": 2], class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
      {key, {:array, _}} ->
        {label(key), ~s(<%= multiple_select f, #{inspect(key)}, ["Option 1": "option1", "Option 2": "option2"] %>), error(key)}
      {key, _}  ->
        {label(key), ~s(<%= text_input f, #{inspect(key)}, class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md" %>), error(key)}
    end)
  end

  defp label(key) do
    ~s(<%= label f, #{inspect(key)}, class: "block text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>)
  end

  defp error(field) do
    ~s(<%= tailwind_error_tag f, #{inspect(field)} %>)
  end

  defp inject_error_helper(%Context{context_app: ctx_app} = context, _paths, _binding) do
    web_prefix = Mix.Phoenix.web_path(ctx_app)
    file_path = Path.join(web_prefix, "views/error_helpers.ex")

    """

      def tailwind_error_tag(form, field) do
        Enum.map(Keyword.get_values(form.errors, field), fn error ->
          content_tag(:p, translate_error(error),
            class: "mt-2 text-sm text-red-500",
            phx_feedback_for: input_name(form, field)
          )
        end)
      end
    """
    |> inject_before_final_end(file_path)

    context
  end

  defp inject_before_final_end(content_to_inject, file_path) do
    with {:ok, file} <- read_file(file_path),
         {:ok, new_file} <- PhxTailwindGenerators.inject_before_final_end(file, content_to_inject) do
      print_injecting(file_path)
      File.write!(file_path, new_file)
    else
      :already_injected ->
        :ok

      {:error, {:file_read_error, _}} ->
        :ok
        # print_injecting(file_path)
        #
        # print_unable_to_read_file_error(
        #   file_path,
        #   """
        #   Please add the following to the end of your equivalent
        #   #{Path.relative_to_cwd(file_path)} module:
        #   #{indent_spaces(content_to_inject, 2)}
        #   """
        # )
    end
  end

  defp read_file(file_path) do
    case File.read(file_path) do
      {:ok, file} -> {:ok, file}
      {:error, reason} -> {:error, {:file_read_error, reason}}
    end
  end

  defp print_injecting(file_path, suffix \\ []) do
    Mix.shell().info([:green, "* injecting ", :reset, Path.relative_to_cwd(file_path), suffix])
  end

end
