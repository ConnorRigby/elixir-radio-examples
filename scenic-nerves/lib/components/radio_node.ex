defmodule Radio.Component.RadioNode do
  @default_font :roboto
  @default_font_size 20
  @intro_animation_time 50

  alias Scenic.Graph
  import Scenic.Primitives
  use Scenic.Component, has_children: false

  alias RF69.Packet

  @doc false
  def info(data) do
    """
    #{IO.ANSI.red()}data must be a Packet struct
    #{IO.ANSI.yellow()}Received: #{inspect(data)}
    #{IO.ANSI.default_color()}
    """
  end

  @doc false
  def verify(%Packet{} = arg), do: {:ok, arg}

  def add_to_graph(graph, data, opts) do
    Scenic.Primitive.SceneRef.add_to_graph(graph, {__MODULE__, data}, opts)
  end

  def init(data, opts) when is_list(opts) do
    id = opts[:id]
    styles = opts[:styles]

    # font related info
    font = @default_font
    font_size = styles[:button_font_size] || @default_font_size

    # build the graph
    graph =
      Graph.build(font: font, font_size: font_size)
      |> add_background(data, id)
      |> add_node_id(data, id)
      |> add_signal_percent(data, id)
      |> add_payload(data, id)

    state = %{
      graph: graph,
      pressed: false,
      contained: false,
      id: id
    }

    {:ok, state, push: graph}
  end

  defp add_background(graph, %Packet{}, id) do
    rrect(graph, {798, 50, 20},
      fill: {73, 82, 97, 180},
      stroke: {1, :white},
      id: {id, :background}
    )
  end

  defp add_node_id(graph, %Packet{sender_id: node_id}, _id) when node_id < 10 do
    graph
    |> rrect({50, 50, 20}, fill: :grey)
    |> text("#{node_id}", translate: {20, 30})
  end

  defp add_node_id(graph, %Packet{sender_id: node_id}, _id) do
    graph
    |> rrect({50, 50, 20}, fill: :grey)
    |> text("#{node_id}", translate: {15, 30})
  end

  defp add_signal_percent(graph, %Packet{rssi_percent: perc}, id) when perc > 75 do
    graph
    # |> circle(7, translate: {60, 15}, fill: :grey)
    |> rrect({10, 15, 3},
      translate: {70 - 16, 33},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :low}
    )
    |> rrect({10, 25, 3},
      translate: {80 - 16, 23},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :med_low}
    )
    |> rrect({10, 35, 3},
      translate: {90 - 16, 13},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :med_high}
    )
    |> rrect({10, 45, 3},
      translate: {100 - 16, 3},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :high}
    )
  end

  defp add_signal_percent(graph, %Packet{rssi_percent: perc}, id) when perc >= 50 do
    graph
    |> rrect({10, 15, 3},
      translate: {70 - 16, 33},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :low}
    )
    |> rrect({10, 25, 3},
      translate: {80 - 16, 23},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :med_low}
    )
    |> rrect({10, 35, 3},
      translate: {90 - 16, 13},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :med_high}
    )
    |> rrect({10, 45, 3},
      translate: {100 - 16, 3},
      fill: :grey,
      stroke: {1, :white},
      id: {id, :perc, :high}
    )
  end

  defp add_signal_percent(graph, %Packet{rssi_percent: perc}, id) when perc >= 25 do
    graph
    |> rrect({10, 15, 3},
      translate: {70 - 16, 33},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :low}
    )
    |> rrect({10, 25, 3},
      translate: {80 - 16, 23},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :med_low}
    )
    |> rrect({10, 35, 3},
      translate: {90 - 16, 13},
      fill: :grey,
      stroke: {1, :white},
      id: {id, :perc, :med_high}
    )
    |> rrect({10, 45, 3},
      translate: {100 - 16, 3},
      fill: :grey,
      stroke: {1, :white},
      id: {id, :perc, :high}
    )
  end

  defp add_signal_percent(graph, %Packet{rssi_percent: perc}, id) when perc < 25 do
    graph
    |> rrect({10, 15, 3},
      translate: {70 - 16, 33},
      fill: :green,
      stroke: {1, :white},
      id: {id, :perc, :low}
    )
    |> rrect({10, 25, 3},
      translate: {80 - 16, 23},
      fill: :grey,
      stroke: {1, :white},
      id: {id, :perc, :med_low}
    )
    |> rrect({10, 35, 3},
      translate: {90 - 16, 13},
      fill: :grey,
      stroke: {1, :white},
      id: {id, :perc, :med_high}
    )
    |> rrect({10, 45, 3},
      translate: {100 - 16, 3},
      fill: :grey,
      stroke: {1, :white},
      id: {id, :perc, :high}
    )
  end

  defp add_payload(graph, %Packet{payload: payload}, id) do
    graph
    |> rrect({600, 40, 20}, translate: {140, 5}, fill: :grey, stroke: {1, :white})
    |> text("data: " <> inspect(payload), translate: {160, 30}, id: {id, :payload})
  end
end
