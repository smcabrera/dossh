defmodule Dossh.Droplets do
   @digital_ocean_url Application.get_env(:dossh, :digital_ocean_url)

  def fetch do
    HTTPoison.get(droplets_url, headers)
    |> handle_response
  end

  def droplets_url do
    "#{@digital_ocean_url}/droplets"
  end

  def handle_response({ :ok, %{status_code: 200, body: body} }) do
    { :ok, body }
    body
    |> Poison.decode
    |> droplets
    |> Enum.map( &droplet_name_and_ip_address(&1) )
  end

  def handle_response({ _, %{status_code: _, body: body} }) do
    { :error, body }
  end

  def droplets( { :ok, droplets } ) do
    droplets["droplets"]
  end

  def droplet_name_and_ip_address(droplet) do
    ip_address = find_ip_address(droplet)
    droplet_name = find_droplet_name(droplet)
    [ { :ip_address, ip_address }, { :droplet_name, droplet_name } ]
  end

  def find_droplet_name(droplet) do
    droplet["name"]
  end

  def find_ip_address(droplet) do
    droplet
    |> networks
    |> ip_address
  end

  def networks(droplets) do
    droplets["networks"]["v4"]
    |> List.first
  end

  def ip_address(networks) do
    networks["ip_address"]
  end

  def headers do
    ["Authorization": "Bearer #{token}", "Accept": "Application/json; Charset=utf-8"]
  end

  def token do
   file = File.read token_filepath
   handle_token(file)
   |> String.trim
  end

  def token_filepath do
    Path.expand("~/.digital_ocean_token")
  end

  def handle_token( {:ok, token} ) do
    token
  end

  def handle_token( {:error, :enoent} ) do
    IO.puts "Expected token at #{token_filepath}. Token file not found"
    System.halt(2)
  end
end
