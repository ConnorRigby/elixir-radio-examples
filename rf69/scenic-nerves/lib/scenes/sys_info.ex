defmodule Radio.Scene.SysInfo do
  use Scenic.Scene
  alias Scenic.Graph
  require Logger

  import Scenic.Primitives
  import Scenic.Components
  alias Scenic.ViewPort
  alias RF69.Packet
  alias Radio.Component.RadioNode

  @graph Graph.build(font_size: 22, font: :roboto_mono)

  def init(args, opts) do
    viewport = opts[:viewport]
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
    IO.inspect(args, label: "args")

    # rf69 = nil
    {:ok, rf69} = RF69.start_link(args)
    Process.send_after(self(), :test_packet, 1500)

    graph =
      @graph
      |> rect({vp_width, vp_height}, id: :background, fill: {51, 51, 51}, stroke: {2, :white})

    # uncomment for demo mode
    # for id <- 1..8, do: send self(), %Packet{sender_id: id, rssi_percent: 100, payload: "test data 12345"}

    {:ok, %{graph: graph, rf69: rf69}, push: graph}
  end

  def handle_info(:test_packet, state) do
    RF69.send(state.rf69, 2, false, "abc")
    {:noreply, state}
  end

  def handle_info(%Packet{sender_id: node_id} = packet, state) do
    Logger.debug("packet received: #{inspect(packet, pretty: true)}")

    num_nodes =
      Graph.find(state.graph, fn
        {:radio_node, _} -> true
        _ -> false
      end)
      |> Enum.count()

    graph =
      case Graph.get(state.graph, {:radio_node, node_id}) do
        [old] ->
          state.graph
          |> Graph.delete({:radio_node, node_id})
          |> RadioNode.add_to_graph(packet,
            id: {:radio_node, node_id},
            translate: old.transforms.translate
          )

        [] ->
          y = if num_nodes == 0, do: 0, else: num_nodes * 55

          RadioNode.add_to_graph(state.graph, packet,
            id: {:radio_node, node_id},
            translate: {1, y + 30}
          )
      end

    {:noreply, %{state | graph: graph}, push: graph}
  end
end
