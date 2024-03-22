
defmodule ElixirChat.RandomIcon do
  def generate do
    random_color = fn -> Enum.random(0..255) end
    color = "rgb(#{random_color.()}, #{random_color.()}, #{random_color.()})"
    x = 75
    y = 61
    r = 25

    # Generate two random letters
    random_letter = fn -> [Enum.random(?A..?Z)] |> List.to_string end
    letters = "#{random_letter.()}-#{random_letter.()}"


    ~s(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
      <circle cx="#{x}" cy="#{y}" r="#{r}" fill="#{color}" />
      <text x="#{x} y="#{y}" dominant-baseline="middle" text-anchor="middle" font-size="20" fill="white">
        #{letters}</text>
    </svg>)
  end

end
