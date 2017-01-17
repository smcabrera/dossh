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
                                     aliases:  [ h:    :help,
                                                 i:    :ip_address,
                                                 n:    :name
                                     ])
    case parse do

      { [ help: true ] }
        -> :help

      { [], ["table"], [] } 
        -> :table

      { [], ["ls"], [] } 
      -> {:ls, nil}

      { [ip_address: true], ["ls"], [] }
        -> {:ls, :ip_address}

      { [name: true], ["ls"], [] }
        -> {:ls, :name}

      #{ [], ["ls"], ["ip-address": true] } 
        #-> :ls
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

  def process({:ls, filter}) do
    Dossh.Droplets.fetch
    |> output_list(filter)
    |> render_list 
  end

  #def process(:ls_just_ip) do
    #Dossh.Droplets.fetch
    #|> ip_address_list
    #|> render_list 
  #end

  #def process(:ls_just_names) do
    #Dossh.Droplets.fetch
    #|> droplet_name_list
    #|> render_list 
  #end

  defp output_list(droplets, :ip_address) do
    Enum.map(droplets, fn(droplet) -> "#{droplet[:ip_address]}" end)
  end

  defp output_list(droplets, :name) do
    Enum.map(droplets, fn(droplet) -> "#{droplet[:droplet_name]}" end)
  end

  defp output_list(droplets, _) do
    Enum.map(droplets, fn(droplet) -> "#{droplet[:droplet_name]}=#{droplet[:ip_address]}" end)
  end

  #defp ip_address_list(droplets) do
    #Enum.map(droplets, fn(droplet) -> "#{droplet[:ip_address]}" end)
  #end

  #defp droplet_name_list(droplets) do
    #Enum.map(droplets, fn(droplet) -> "#{droplet[:droplet_name]}" end)
  #end

  #def names_and_ip_addresses_list(droplets) do
    #Enum.map(droplets, fn(droplet) -> "#{droplet[:droplet_name]}=#{droplet[:ip_address]}" end)
  #end

  def render_list(list) do
    list
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
