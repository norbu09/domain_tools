defmodule DomainTools do
  require Logger

  @moduledoc """
  DomainTools imports the suffix list and splits domains based on that list.
  This means we can make sure a domain is a valid domain if it splits
  correctly, it also does IDN conversion to make sure we use only ascii
  internally and can display unicode domain names if required.
  """
  @public_suffix_list_url 'https://raw.githubusercontent.com/publicsuffix/list/master/public_suffix_list.dat'
  @local_path "#{DomainTools.Utils.data_dir()}/public_suffix_list.dat"
  # TODO: release as module on hex

  use GenServer

  def start_link() do
    start_link([])
  end

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc """
  ## Examples
  iex> DomainTools.validate("someone.com")
  {:ok, %{domain: "someone.com", tld: "com", host: "someone", unicode: "someone.com"}}
  iex> DomainTools.validate("blog.someone.id.au")
  {:ok, %{domain: "blog.someone.id.au", host: "blog.someone", tld: "id.au", unicode: "blog.someone.id.au"}}
  iex> DomainTools.validate("zen.xn--unup4y")
  {:ok, %{domain: "zen.xn--unup4y", host: "zen", tld: "xn--unup4y", unicode: "zen.游戏"}}
  iex> DomainTools.validate("zen.游戏")
  {:ok, %{domain: "zen.xn--unup4y", host: "zen", tld: "xn--unup4y", unicode: "zen.游戏"}}
  """
  def validate(domain) do
    GenServer.call(__MODULE__, {:validate, domain})
  end

  def update do
    GenServer.cast(__MODULE__, {:update})
  end

  def save(string) do
    GenServer.cast(__MODULE__, {:save, string})
  end

  @impl true
  def init(_) do
    :inets.start()
    :ssl.start()

    __MODULE__.update()
    {:ok, %{}}
  end

  @impl true
  @impl true
  def handle_call({:validate, idn}, _from, suffixes) do
    domain = to_ascii(idn)

    tld =
      domain
      |> to_ascii
      |> String.split(".")
      |> Enum.drop(1)
      |> Enum.reverse()
      |> get_tld(suffixes)

    uni = to_uni(domain)

    {host, _} = String.split_at(domain, -String.length(tld) - 1)
    {:reply, {:ok, %{domain: domain, tld: tld, host: host, unicode: uni}}, suffixes}
  end

  def handle_cast({:save, string}, suffixes) do
    File.mkdir_p!(DomainTools.Utils.data_dir())
    case File.write(@local_path, string) do
      :ok -> Logger.info("Public suffix list updated")
      {:error, error} -> Logger.error("Could not save public suffix list locally: #{inspect error}")
    end
    {:noreply, suffixes}
  end

  @impl true
  def handle_cast({:update}, suffixes) do
    list =
      case :httpc.request(:get, {@public_suffix_list_url, []}, [], [{:body_format, :binary}]) do
        {:ok, {{_ver, 200, _status}, _, string}} ->
          __MODULE__.save(string)
          string

        _ ->
          case File.read(@local_path) do
            {:ok, string} ->
              Logger.warn(
                "[DomainTools] Could not read the public suffix list from the internet, trying to read from the backup at #{
                  @local_path
                }"
              )

              string

            _ ->
              Logger.error(
                "[DomainTools] Could not read the public suffix list, please make sure that you either have an internet connection or #{
                  @local_path
                } exists"
              )

              nil
          end
      end

    string = list |> String.split("// ===END ICANN DOMAINS===") |> List.first()

    suffixes =
      string
      |> String.split("\n")
      |> Enum.reject(&(&1 == ""))
      |> Enum.reject(&String.contains?(&1, "//"))
      |> Enum.reject(&String.contains?(&1, "*"))
      |> Enum.reject(&String.starts_with?(&1, "!"))
      |> Enum.map(&to_ascii(&1))
      |> Enum.map(&String.split(&1, "."))
      |> Enum.map(&Enum.reverse/1)
      |> Enum.sort_by(&length/1)
      |> Enum.reverse()
      |> build_tree(%{})

    {:noreply, suffixes}
  end

  defp get_tld([], _suffixes) do
    ""
  end

  defp get_tld(list, suffixes) do
    case get_in(suffixes, list) do
      nil ->
        get_tld(Enum.drop(list, -1), suffixes)

      _ ->
        list
        |> Enum.reverse()
        |> Enum.join(".")
    end
  end

  defp to_ascii(string) do
    string
    |> to_charlist
    |> try_idna
    |> to_string
  end

  defp to_uni(string) do
    string
    |> to_charlist
    |> try_uni
    |> to_string
  end

  defp try_idna(string) do
    try do
      :idna.encode(string, [:uts46])
    catch
      :exit, value ->
        Logger.error("Could not parse #{string}: #{inspect(value)}")
        string
    end
  end

  defp try_uni(string) do
    try do
      :idna.decode(string)
    catch
      :exit, value ->
        Logger.error("Could not parse #{string}: #{inspect(value)}")
        string
    end
  end

  defp build_tree([head | tail], acc) when is_list(head) do
    deep_merge(build_tree(head, acc), build_tree(tail, acc))
  end

  defp build_tree([head | tail], acc) when is_binary(head) do
    Map.put(acc, head, build_tree(tail, acc))
  end

  defp build_tree([], acc) do
    acc
  end

  defp deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  defp deep_resolve(_key, left = %{}, right = %{}) do
    deep_merge(left, right)
  end
  defp deep_resolve(_key, _left, right) do
    right
  end

end
