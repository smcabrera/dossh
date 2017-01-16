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
  `argv` can be
    -h or --help, which returns :help.
    table, which will return a table of names and ip addresses of the user's digital ocean droplets
  """

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ "help": :boolean, "ip-address": :boolean, "name": :boolean],
                                     aliases:  [ h:    :help ])
    case parse do

      { [ help: true ] }
        -> :help

      { [], ["table"], [] } 
        -> :table

      { [], ["ls"], [_] } 
        -> :ls

    end
  end

  def process(:help) do
    IO.puts """
      usage: dossh table
      outputs a table of digital ocean droplets with their names and ip addresses. Uses a token stored in a dotfile in the user's home directory: ~/.digital_ocean_token

      dossh ls [-id]
      lists ip addresses or droplet names. Defaults to both if no options specified. Separated by an equals sign

      examples: 
      $ dossh ls -i
      192.34.785
      184.62.849

      $ dossh ls -d
      ubuntu-64-1
      ubuntu-64-2

      $ dossh ls
      ubuntu-64-1=192.34.785
      ubuntu-64-2=184.62.849
    """
    System.halt(0)
  end

  def process(:table) do
    Dossh.Droplets.fetch
    |> render_table
  end

  def process(:ls) do
    Dossh.Droplets.fetch
    |> render_list 
  end

  def render_list(droplets) do
    Enum.map(droplets, fn(droplet) -> "#{droplet[:droplet_name]}=#{droplet[:ip_address]}" end)
    |> Enum.join("\n")
    |> IO.puts
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
