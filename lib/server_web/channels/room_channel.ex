defmodule ServerWeb.RoomChannel do
  use ServerWeb, :channel


  @impl true
  @spec join(<<_::80>>, any, any) :: {:ok, any}
  def join("room:" <> _room_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  @spec handle_in(<<_::32, _::_*8>>, any, any) ::
          {:noreply, Phoenix.Socket.t()} | {:reply, {:ok, any}, any}
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("joined", payload, socket) do
    broadcast(socket, "joined", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_guess", payload, socket) do
    broadcast(socket, "new_guess", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
