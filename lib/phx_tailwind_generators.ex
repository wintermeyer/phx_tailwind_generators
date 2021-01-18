defmodule PhxTailwindGenerators do
  @moduledoc """
  Documentation for `PhxTailwindGenerators`.
  """

  def tailwind_error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:p, translate_error(error),
        class: "mt-2 text-sm text-red-500",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

end
