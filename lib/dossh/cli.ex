defmodule Dossh.CLI do
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table digital ocean droplets with their names and ip addresses
  """
  def main(argv) do
    argv
      |> parse_args
      |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.
   if no arguments are given it will simply return the table of names and ip addresses
  """

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ],
                                     aliases:  [ h:    :help ])
    case parse do

      { [ help: true ], _, _ }
        -> :help

      _ -> :ip_address

    end
  end

  def process(:help) do
    IO.puts """
      usage: dossh 
      lists digital ocean droplets and ip addresses using a token stored in a dotfile in the user's home directory ~/.digital_ocean_token
    """
    System.halt(0)
  end

  def process(:ip_address) do
    Dossh.Droplets.fetch
    |> render_table
  end

  def droplet_info_string(droplet) do
    " #{droplet[:droplet_name]}, ip address: #{droplet[:ip_address]}"
  end

  def render_table(droplets) do
    header = ["Droplet Name", "IP Address"]
    TableRex.quick_render!(rows(droplets), header)
    |> IO.puts 
  end

  def rows(droplets) do
    Enum.map(droplets, fn(droplet) -> [droplet[:droplet_name], droplet[:ip_address]] end )
  end
end
